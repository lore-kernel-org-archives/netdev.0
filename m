From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v3 3/6] can: make struct proto const
Date: Mon, 14 Mar 2011 17:42:23 +0100
Message-ID: <1300120943.3423.121.camel@edumazet-laptop>
References: <20110314132004.GA333@e-circ.dyndns.org>
	 <20110314134721.GD333@e-circ.dyndns.org>
	 <1300111755.3423.20.camel@edumazet-laptop>
	 <20110314150227.GJ333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54706 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630Ab1CNQnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:43:43 -0400
Received: by fxm17 with SMTP id 17so3086562fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 09:43:42 -0700 (PDT)
In-Reply-To: <20110314150227.GJ333@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 16:02 +0100, Kurt Van Dijck a =C3=A9crit :

> I see your point.
> The reason I modified this was, as described, checkpatch.pl was compl=
aining.
> Anyway, this sequence was protected by a spinlock 'proto_tab_lock'.
> I don't think it was a race.
>=20
> Did I miss something?

As soon as proto_tab[proto] =3D cp; is done, another thread on another =
cpu
can read the pointer and follow it.

Hmm, I missed can_create() also uses the spinlock protection, so you're
probably right.

It seems a bit overkill :(
phonet uses RCU for example.


