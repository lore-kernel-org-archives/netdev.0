From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: root_lock vs. device's TX lock
Date: Thu, 17 Nov 2011 17:34:58 +0100
Message-ID: <1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54981 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809Ab1KQQfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 11:35:03 -0500
Received: by bke11 with SMTP id 11so2230020bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 08:35:02 -0800 (PST)
In-Reply-To: <CA+mtBx8sHDprEct3zgGXXKEESK6i0FYnFS-_z35FOyVQjS9R4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 08:10 -0800, Tom Herbert a =C3=A9crit =
:
> From sch_direct_xmit:
>=20
>         /* And release qdisc */
>         spin_unlock(root_lock);
>=20
>         HARD_TX_LOCK(dev, txq, smp_processor_id());
>         if (!netif_tx_queue_frozen_or_stopped(txq))
>                 ret =3D dev_hard_start_xmit(skb, dev, txq);
>=20
>         HARD_TX_UNLOCK(dev, txq);
>=20
>         spin_lock(root_lock);
>=20
> This is a lot of lock manipulation to basically switch from one lock
> to another and possibly thrashing just to send a packet.  I am
> thinking that if the there is a 1-1 correspondence between qdisc and
> device queue then we could actually use the device's lock as the root
> lock for the qdisc.  So in that case, we would need to touch any lock=
s
> from sch_direct_xmit (just hold root lock which is already device loc=
k
> for the duration).
>=20
> Is there any reason why this couldn't work?

But we have to dirty part of Qdisc anyway ?
(state, bstats, q, ...)
