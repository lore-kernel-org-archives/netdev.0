From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in
 pppoe_flush_dev()
Date: Mon, 05 Oct 2015 03:05:00 -0700 (PDT)
Message-ID: <20151005.030500.1845779775642013934.davem@davemloft.net>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, core@irc.lg.ua,
	nuclearcat@nuclearcat.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbJEJtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:49:21 -0400
In-Reply-To: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 30 Sep 2015 11:45:33 +0200

> Since commit 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release"),
> pppoe_release() calls dev_put(po->pppoe_dev) if sk is in the
> PPPOX_ZOMBIE state. But pppoe_flush_dev() can set sk->sk_state to
> PPPOX_ZOMBIE _and_ reset po->pppoe_dev to NULL. This leads to the
> following oops:
 ...
> pppoe_flush_dev() has no reason to override sk->sk_state with
> PPPOX_ZOMBIE. pppox_unbind_sock() already sets sk->sk_state to
> PPPOX_DEAD, which is the correct state given that sk is unbound and
> po->pppoe_dev is NULL.
> 
> Fixes: 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release")
> Tested-by: Oleksii Berezhniak <core@irc.lg.ua>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
