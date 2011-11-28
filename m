From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [NET][TG3] Fwd: page allocation failure with linux 3.1.1
Date: Mon, 28 Nov 2011 09:26:02 +0100
Message-ID: <1322468762.2826.17.camel@edumazet-laptop>
References: <CALkh-HhkzHb7-2LAwCNOZ-S4otfeM+tthyw2_XDbDUjFRSkKjA@mail.gmail.com>
	 <CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com>
	 <1322462145.2826.6.camel@edumazet-laptop>
	 <CALkh-Hi=Pb_cNUzHrJSe4o5-kmb+jLA8vpw8hiaGxROzNJ6oag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9F=D0=BB=D0=B0=D0=BC=D0=B5=D0=BD_?=
	 =?UTF-8?Q?=D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2?=
	<plamen.sisi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:53751 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab1K1I0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 03:26:07 -0500
Received: by vcbfk14 with SMTP id fk14so3413997vcb.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 00:26:05 -0800 (PST)
In-Reply-To: <CALkh-Hi=Pb_cNUzHrJSe4o5-kmb+jLA8vpw8hiaGxROzNJ6oag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 09:16 +0200, =D0=9F=D0=BB=D0=B0=D0=BC=D0=
=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2 a =C3=A9crit :

> Well, Eric, thanks for the explanation! I will disable TSO and will
> see how is that working out for me - if I recall correctly, I had no
> problems when TSO was off.
>=20
> Sorry to bother you, if the above explanation was somewhere readily
> available, but I didn't manage to find it.

You dont bother me at all :)

As a matter of fact, your mail reminded me something I wanted to do in
the past and forgot about.

Since some devices might copy skb to a linear one in their
ndo_start_xmit(), we could set a netdev limit so that TSO can still be
used on these devices, but limiting number of frags to
2^PAGE_ALLOC_COSTLY_ORDER

(Since PAGE_ALLOC_COSTLY_ORDER =3D=3D 3, thats 8 frags, instead of 16 r=
ight
now on x86)

Of course, if memory is really tight, even an ATOMIC order-3 allocation
might fail. If this happens, device limit could be dynamically
decreased. In the end, only linear skb could be built by TCP.
