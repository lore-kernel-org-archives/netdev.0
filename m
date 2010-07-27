From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Tx queue selection
Date: Tue, 27 Jul 2010 13:57:52 +0200
Message-ID: <1280231872.2827.143.camel@edumazet-laptop>
References: <1280227867.1970.208.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55013 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291Ab0G0L55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 07:57:57 -0400
Received: by wwj40 with SMTP id 40so1095918wwj.1
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 04:57:56 -0700 (PDT)
In-Reply-To: <1280227867.1970.208.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 juillet 2010 =C3=A0 20:51 +1000, Benjamin Herrenschmidt a =C3=
=A9crit :
> Hi folks !
>=20
> I'm putting my newbie hat on ... :-)
>=20
> While looking at our ehea driver (and in fact another upcoming driver
> I'm helping with), I noticed it's using the "old style" multiqueue. I=
E.
> It doesn't use the alloc_netdev_mq() variant, creates one queue on th=
e
> linux side, an makes its own selection of HW queue in start_xmit.
>=20
> This had many drawbacks, obviously, such as not getting per-queue loc=
ks
> etc...
>=20
> Now, the mechanics of converting that to the new scheme are easy enou=
gh
> to figure out by reading the code. However, where my lack of networki=
ng
> background fails me is when it comes to the policy of choosing a Tx
> queue.
>=20
> ehea uses its own hash of the header, different from the "default" qu=
eue
> selection in the net core. Looking at other drivers such as ixgbe, I =
see
> that it can chose to use smp_processor_id() when a flag is set for wh=
ich
> I don't totally understand the meaning or default to the core algorit=
hm.
>=20
> Now, while I can understand why it's a good idea to use the current
> processor, in order to limit cache ping pong etc... I'm not really
> confident I understand the pro/cons of using the hashing for tx. I
> understand that the net core can play interesting games with associat=
ing
> sockets with queues etc... but I'm a bit at a loss when it comes to
> deciding what's best for this driver. I suppose I could start by
> implementing my own queue selection based on what ehea does today but=
 I
> have the nasty feeling that's going to be sub-optimal :-)
>=20
> So I would very much appreciate (and reward with free beer at the nex=
t
> conference) if somebody could give me a bit of a heads up on how thin=
gs
> are expected to be done there, pro/cons, perf impact etc...

I am not sure ndo_select_queue() is really needed these days. It was
done before core network was able to use a socket provided hash.

tx queue selection done by default (skb_tx_hash()) should be fine.

bnx2 for example doesnt provide a ndo_select_queue()



