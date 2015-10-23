From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix pppoe_dev deletion condition in
 pppoe_release()
Date: Fri, 23 Oct 2015 03:30:48 -0700 (PDT)
Message-ID: <20151023.033048.1984003889137051787.davem@davemloft.net>
References: <6a9ae28f4128939528dcf64795f1de88b39a6118.1445525554.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org,
	nuclearcat@nuclearcat.com, Matt.Bennett@alliedtelesis.co.nz
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbbJWKOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 06:14:18 -0400
In-Reply-To: <6a9ae28f4128939528dcf64795f1de88b39a6118.1445525554.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 22 Oct 2015 16:57:10 +0200

> We can't rely on PPPOX_ZOMBIE to decide whether to clear po->pppoe_dev.
> PPPOX_ZOMBIE can be set by pppoe_disc_rcv() even when po->pppoe_dev is
> NULL. So we have no guarantee that (sk->sk_state & PPPOX_ZOMBIE) implies
> (po->pppoe_dev != NULL).
> Since we're releasing a PPPoE socket, we want to release the pppoe_dev
> if it exists and reset sk_state to PPPOX_DEAD, no matter the previous
> value of sk_state. So we can just check for po->pppoe_dev and avoid any
> assumption on sk->sk_state.
> 
> Fixes: 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
