From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 22 Dec 2011 19:34:21 +0100
Message-ID: <CAHXqBF+U8g16M8_MvFSmOWrLrfiAnuOzn0Mzn9uurLpQym+m4A@mail.gmail.com>
References: <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1324475280.7877.33.camel@zakaz.uk.xensource.com> <1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111221.142841.2253787084484360430.davem@davemloft.net> <1324550017.7877.77.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53633 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab1LVSem convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 13:34:42 -0500
Received: by iaeh11 with SMTP id h11so13855465iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 10:34:42 -0800 (PST)
In-Reply-To: <1324550017.7877.77.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/22 Ian Campbell <Ian.Campbell@citrix.com>:
> On Wed, 2011-12-21 at 19:28 +0000, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 21 Dec 2011 15:02:18 +0100
>> > No idea on this +2 point.
>> I think I know, and I believe I instructed Alexey Kuznetsov to do
>> this.
>>
>> When sendfile() is performed, we might start the SKB with the last f=
ew
>> bytes of one page, and end the SKB with the first few bytes of anoth=
er
>> page.
>>
>> In order to fit a full 64K frame into an SKB in this situation we ha=
ve
>> to accomodate this case.
> Thanks David, that makes sense.
>
> However I think you only actually need 1 extra page for that. If the
> data in frag[0] starts at $offset then frag[16] will need to have
> $offset bytes in it. e.g.
> =A0 =A0 =A0 =A04096-$offset + 4096*15 + $offset =3D 65536
> which =3D=3D 17 pages rather than 18.
>
> The following documents the status quo but I could update to switch t=
o +
> 1 instead if there are no flaws in the above logic...

Since max IP datagram is 64K-1, adding ethernet and possibly VLAN
headers makes the max size slightly above 64K and then you have
64K/PAGE_SIZE+2 pages appear in worst case.

Best Regards,
Micha=B3 Miros=B3aw
