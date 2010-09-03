From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Frag list lost on head expansion.
Date: Fri, 03 Sep 2010 08:19:28 +0200
Message-ID: <1283494768.3699.1507.camel@edumazet-laptop>
References: <20100902.204332.02275687.davem@davemloft.net>
	 <1283492880.3699.1437.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:38315 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab0ICGTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 02:19:33 -0400
Received: by wwi18 with SMTP id 18so191891wwi.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 23:19:32 -0700 (PDT)
In-Reply-To: <1283492880.3699.1437.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 07:48 +0200, Eric Dumazet a =C3=A9=
crit :

> David, I had this same idea some days ago when reviewing this code,
> but when I came to conclusion we could not avoid the get_page /
> put_page() on skb_shinfo(skb)->frags[i].page. I thought it was not wo=
rth
> trying to avoid the frag_list grab/release operation.
>=20
> But we are the only user of this skb and skb_shinfo(skb)->frag_list, =
so
> your patch seems good to me.
>=20
> Please note you are not fixing a bug, because the new frag_list point=
er
> was correctly copied in the
>=20
> memcpy(data + size, skb_end_pointer(skb),=20
> 	offsetof(struct skb_shared_info,
> 		frags[skb_shinfo(skb)->nr_frags]));
>=20
> Please rewrite the changelog to say this patch is an optimization, to
> avoid the atomic ops on each skb found in frag_list ?
>=20

Well, skb is not shared, but we have no guarantee skb_shinfo(skb) is
not.

To optimize this thing, you'll need to add a new parameter to
skb_release_data() ?


