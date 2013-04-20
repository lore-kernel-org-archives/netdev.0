From: Vincent JARDIN <vincent.jardin@6wind.com>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Sun, 21 Apr 2013 01:20:02 +0200
Message-ID: <33F61BD9-8C2F-44E9-98BF-CD2D4C241A94@6wind.com>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net> <20130419194537.GA1633@kroah.com> <20130419.155859.1092595631804890737.davem@davemloft.net> <51727C76.6010501@redhat.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Eric Leblond <eric@regit.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:62435 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879Ab3DTXZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 19:25:30 -0400
Received: by mail-we0-f175.google.com with SMTP id t11so5022530wey.34
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 16:25:29 -0700 (PDT)
In-Reply-To: <51727C76.6010501@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+1=20

Even if DPDK (see http://dpdk.org) offers some alternatives with better=
 performances ; Netmap is a usable option and a good compromise.

I think both shall coexist.

Best regards,
  Vincent

Le 20 avr. 2013 =C3=A0 13:31, Daniel Borkmann <dborkman@redhat.com> a =C3=
=A9crit :

> On 04/19/2013 09:58 PM, David Miller wrote:
>> From: Greg KH <gregkh@linuxfoundation.org>
>> Date: Fri, 19 Apr 2013 12:45:37 -0700
>>=20
>>> On Fri, Apr 19, 2013 at 12:06:51PM -0700, Stephen Hemminger wrote:
>>>> Netmap is a framework for packet generation and capture from user
>>>> space. It allows for efficient packet handling (up to line rate on
>>>> 10Gb) with minimum system load.  For more info see:
>>>>    http://info.iet.unipi.it/~luigi/netmap/
>>=20
>> So are you saying that people can't get line rate today?
>>=20
>> Even the the suricata folks are doing deep packet inspection at line
>> rate using AF_PACKET fanouts just fine.  That means they aren't just
>> grabbing packets, they are actually processing them and making
>> stateful decisions based upon the packet's contents.
>>=20
>> That means that capture is cheap enough already that they have all
>> the compute left over that they need.
>>=20
>> The existing mechanisms also have the huge advantage that they are
>> already implemented, require zero driver specific changes, and are
>> already starting to be deployed to end users.
>=20
> +1, and if so, then I'm actually rather for further improving/optimiz=
ing/..
> AF_PACKET. Btw., Eric had a blog post from 2012 about this topic (and
> maybe TPACKET_V3 could even further improve perf. over TPACKET_V2 on =
this):
>=20
>  https://home.regit.org/2012/07/suricata-to-10gbps-and-beyond/
>=20
> Also, I just looked over Netmap's Usenix paper from 2012, where they =
compare
> netmap against pktgen, and while they state the version of the FreeBS=
D kernel
> where they did the evaluation on, they just don't even mention the Li=
nux'
> kernel version, their Linux kernel setup etc. Not even mentioning a c=
omparison
> of PF_PACKET+fanout (similarly as the PF_RING project seems to avoid =
this
> comparison and only presents perf numbers where they just count packe=
ts !).
> Also, I've seen other papers published in 2012 on this topic, where t=
hey
> compare performance with a 2.6.2x kernel, hm, quite sad actually.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
