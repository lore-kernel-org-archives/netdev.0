From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix loop in ofo handling code and reduce
 its complexity
Date: Fri, 29 May 2009 15:02:41 -0700 (PDT)
Message-ID: <20090529.150241.92282161.davem@davemloft.net>
References: <Pine.LNX.4.64.0905291552240.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753717AbZE2WCl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 18:02:41 -0400
In-Reply-To: <Pine.LNX.4.64.0905291552240.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 29 May 2009 16:03:45 +0300 (EEST)

> Somewhat luckily, I was looking into these parts with very fine
> comb because I've made somewhat similar changes on the same
> area (conflicts that arose weren't that lucky though). The loop
> was very much overengineered recently in commit 915219441d566
> (tcp: Use SKB queue and list helpers instead of doing it
> by-hand), while it basically just wants to know if there are
> skbs after 'skb'.
>=20
> Also it got broken because skb1 =3D skb->next got translated into
> skb1 =3D skb1->next (though abstracted) improperly. Note that
> 'skb1' is pointing to previous sk_buff than skb or NULL if at
> head. Two things went wrong:
> - We'll kfree 'skb' on the first iteration instead of the
>   skbuff following 'skb' (it would require required SACK reneging
>   to recover I think).
> - The list head case where 'skb1' is NULL is checked too early
>   and the loop won't execute whereas it previously did.
>=20
> Conclusion, mostly revert the recent changes which makes the
> cset very messy looking but using proper accessor in the
> previous-like version.
>=20
> The effective changes against the original can be viewed with:
>   git-diff 915219441d566f1da0caa0e262be49b666159e17^ \
> 		net/ipv4/tcp_input.c | sed -n -e '57,70 p'
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks a lot for catching this!
