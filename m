From: =?UTF-8?B?U3JlxIdrbyBKdXJpxIctS2F2ZWxq?=
	<srecko.juric-kavelj@fer.hr>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 20:35:30 +0200
Message-ID: <CAACrLC0eVZJdu802Ff4BWRBKuabS=Z-T3WvZCxyqBTem8-n8ug@mail.gmail.com>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
	<CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
	<4FBFAC30.8050508@genband.com>
	<CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
	<CAACrLC0b5dyjJM=DGf-9nUOwar3O9EVTTR0tvynQj285EDpfwA@mail.gmail.com>
	<1337964880.3347.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Chris Friesen <chris.friesen@genband.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43898 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441Ab2EYSfb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 14:35:31 -0400
Received: by obbtb18 with SMTP id tb18so1536388obb.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 11:35:30 -0700 (PDT)
In-Reply-To: <1337964880.3347.52.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 25, 2012 at 6:54 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> linux TCP uses high precision timestamps (ktime_get_real()) where
> needed.
>
> # find net|xargs grep -n TCP_CONG_RTT_STAMP
> net/ipv4/tcp_veno.c:205: =C2=A0 =C2=A0 =C2=A0 =C2=A0.flags =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=3D TCP_CONG_RTT_STAMP,
> net/ipv4/tcp_vegas.c:308: =C2=A0 =C2=A0 =C2=A0 .flags =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0=3D TCP_CONG_RTT_STAMP,
> net/ipv4/tcp_cubic.c:478: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 cubictcp.flags |=3D TCP_CONG_RTT_STAMP;
> net/ipv4/tcp_output.c:815: =C2=A0 =C2=A0 =C2=A0if (icsk->icsk_ca_ops-=
>flags & TCP_CONG_RTT_STAMP)
> net/ipv4/tcp_lp.c:317: =C2=A0.flags =3D TCP_CONG_RTT_STAMP,
> net/ipv4/tcp_yeah.c:229: =C2=A0 =C2=A0 =C2=A0 =C2=A0.flags =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=3D TCP_CONG_RTT_STAMP,
> net/ipv4/tcp_illinois.c:326: =C2=A0 =C2=A0.flags =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0=3D TCP_CONG_RTT_STAMP,
> net/ipv4/tcp_input.c:3496: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ca_op=
s->flags & TCP_CONG_RTT_STAMP &&

Didn't know about TCP_CONG_RTT_STAMP.

Thing is, the device I'm connecting to doesn't even support TCP time
stamp option. The returning SYN ACK packet only has maximum segment
size 1460 bytes in options.

=46rom the net/ipv4/tcp_input.c code, RTT is estimated using

#define tcp_time_stamp          ((__u32)(jiffies))

from include/net/tcp.h.

Could ktime_get_real() be used for tcp_time_stamp instead of jiffies?


> Other than that HZ=3D1000 seems fine.
>
> HZ=3D100 seems a poor choice, we have NO_HZ since a long time.

I have:
$ grep HZ /boot/config-2.6.32-41-generic
CONFIG_NO_HZ=3Dy
CONFIG_HZ_100=3Dy
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=3D100
CONFIG_MACHZ_WDT=3Dm

=46rom what I've seen in the code, NO_HZ doesn't make jiffies go away,
it simply doesn't use regular CONFIG_HZ interrupt to update, but
updates them when has an opportunity?

--
JKS
