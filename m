From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Fri, 20 Aug 2010 23:16:27 -0500
Message-ID: <AANLkTimJAOsJQJ73=xummDuz_xgiyzhSXLJV=VEY=XVx@mail.gmail.com>
References: <AANLkTik9=TcMWzNyKWYyDu+bbGscPne6++gD42aju9s_@mail.gmail.com>
	<AANLkTi=qP7BO2=Uhx2Xb0XiLbUz0mPutbg0vz6QnMgYb@mail.gmail.com>
	<AANLkTim+1=4VCmY=fO5HTvDwKnveGEPsY1h1O64vnT6L@mail.gmail.com>
	<20100819.170649.212693227.davem@davemloft.net>
	<AANLkTimSishHmLTQ9RF8zMq_eOBQ+HiBroKoygFS27-x@mail.gmail.com>
	<AANLkTi=T_=Dy8EhOOyevLd4yj1cy2P8ytXUPS=Y-d6hK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36068 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab0HUEQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 00:16:28 -0400
Received: by iwn5 with SMTP id 5so1487909iwn.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 21:16:28 -0700 (PDT)
In-Reply-To: <AANLkTi=T_=Dy8EhOOyevLd4yj1cy2P8ytXUPS=Y-d6hK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 20, 2010 at 12:35 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Aug 20, 2010 at 1:16 PM, Steve Chen <schen@mvista.com> wrote:
>>
>> On Thu, Aug 19, 2010 at 7:06 PM, David Miller <davem@davemloft.net> =
wrote:
>> > From: Steve Chen <schen@mvista.com>
>> > Date: Thu, 19 Aug 2010 13:35:14 -0500
>> >
>> >> I trace through the code. =A0It appears that the network driver (=
e1000e
>> >> for my setup) always set ip_summed to CHECKSUM_UNNECESSARY. =A0I =
have
>> >> been unsuccessful to get the driver to take the other branch wher=
e
>> >> ip_summed is set to CHECKSUM_COMPLETE. =A0Even when I hard code
>> >> ip_summed to CHECKSUM_COMPLETE, __skb_checksum_complete_head set
>> >> ip_summed to CHECKSUM_UNNECESSARY after recomputing the checksum.
>> >>
>> >> So far the only way I'm able to get ICMP to recompute checksum is
>> >> through the attached hack. =A0Even though I can get all the tests=
 to
>> >> pass, but it just seem wrong.
>> >
>> > If turning off hardware RX checksumming with ethtool has no effect=
,
>> > and the problem is seen with multiple ethernet cards, the problem
>> > is elsewhere.
>> >
>> > First of all, if you turn RX checksumming off, the checksum field
>> > of the SKB should always be skb->ip_summed =3D 0. =A0If this is no=
t
>> > happening, find out why.
>>
>> Ahhh, thats my problem. =A0I incorrectly thought the ip_summed shoul=
d be
>> 2. =A0The ip_summed is set to 1 in
>> __skb_checksum_complete_head. =A0Looking at the code, shouldn't
>>
>> if (likely(!sum))
>>
>> be
>>
>> if (likely(sum))
>>
>> Since sum =3D=3D 0 would indicate an error?
>
> sum =3D=3D 0 indicates that the checksum is correct.
> If you compute the checksum of a packet containing the correct checks=
um the
> result is 0. =A0It's like a slightly more complicated varient of a pa=
rity bit.

It appears the issue lies somewhere within CONNTRACK.  A co-worker
tested with CONNTRACK disable, and the test passed.  Looks like I have
a bit of homework to do.  Thank you for all the helpful hints that got
me this far.

Steve
