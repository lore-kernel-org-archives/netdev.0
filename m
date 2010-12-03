From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 03 Dec 2010 12:29:03 +0100
Message-ID: <1291375743.2897.141.camel@edumazet-laptop>
References: <20101203103447.GA29714@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50401 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758224Ab0LCL3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 06:29:08 -0500
Received: by wyb28 with SMTP id 28so9322892wyb.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 03:29:07 -0800 (PST)
In-Reply-To: <20101203103447.GA29714@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 02:34 -0800, Simon Kirby a =C3=
=A9crit :
> Hello!
>=20
> We upgraded some LVS (DR) servers from 2.6.35 to 2.6.36 on tg3 cards
> (partno(BCM95721) rev 4201) with VLAN tags in use, to think that
> everything looked great, but in fact...
>=20
> LVS was receiving magically-merged TCP packets which it tried to forw=
ard
> on to the real server, only to get annoyed at itself for trying to
> forward a packet bigger than the device MTU:
>=20
> IP A.47376 > B.529: . 175488:176936(1448) ack 1 win 92 <nop,nop,times=
tamp 52737308 29656081>
> IP A.47376 > B.529: . 176936:179832(2896) ack 1 win 92 <nop,nop,times=
tamp 52737325 29656098>
> IP B > A: ICMP B unreachable - need to frag (mtu 1500), length 556
>=20

Hi Simon

This is a tcpdump on A ?
Could you take it also on B ?

tcpdump displays large buffers, but they should be split (of course)
when sent on wire.

> This caused packet loss for any merged frames, which caused abysmal
> performance for uploads via the LVS server.  Local performance to or
> from the box is still fine, because the stack doesn't care, only the
> forwarding part of LVS is running into the problem.
>=20
> Furthermore, disabling _everything_ reported by ethtool -k doesn't se=
em
> to change the result, even if I down/up the interface after, and even=
 if
> I try on every single interface including the VLANned ones.  This see=
ms
> to be another bug.  Reverting to 2.6.35 makes it all work again.
>=20
> Possibly related to commit 7fe876af921d1d2bc8353e0062c10ff35e902653
>=20
> So how should this be fixed?  Should LVS be taught to fragment, or mu=
st
> we disable the merging in this case?  It seems like it would work wel=
l if
> the sending side could do the same offload in reverse, but I'm not su=
re
> if that would be possible.
>=20
> Simon-


I believe Simon Horman has some patches for GRO and LVS.

Please send the results of "ethtool -k eth0" on all your nics / vlans ?

=46or TSO, I am not sure why and where it could matter...



