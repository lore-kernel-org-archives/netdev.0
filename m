From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 17:43:28 +0200
Message-ID: <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1311950488.2843.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E32C76B.5010700@hippy.csoma.elte.hu>
	 <1311952306.2843.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729.081902.300678107767426313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40705 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab1G2Pnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 11:43:32 -0400
Received: by wwe5 with SMTP id 5so3701694wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 08:43:31 -0700 (PDT)
In-Reply-To: <20110729.081902.300678107767426313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 08:19 -0700, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jul 2011 17:11:46 +0200
>=20
> > Thats tricky, because I am not sure we dont need RCU protection sin=
ce we
> > can now exchange dst neighbour on the fly.
> >=20
> > Following patch would only reduce the window of bug, not a complete
> > fix...
> >=20
> > David, any opinion on this ?
>=20
> Indeed, old code worked because we invalidated entire route cache
> entry, and we never before ran arp_bind_neighbour() except on new
> route cache entires before they become globally visible.
>=20
> I think when we change an existing neigh we will need to release old
> neigh via RCU, at a minimum.


Oh well, we already use RCU in neigh_destroy(), so adding rcu would nee=
d
to change all dst_get_neighbour() callers to be in one rcu_read_lock()
section.

I'll take a look, I suspect its mostly already done.



