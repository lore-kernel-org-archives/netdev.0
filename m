From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix net_gso_ok for new GSO types.
Date: Thu, 28 Apr 2016 15:53:36 -0400 (EDT)
Message-ID: <20160428.155336.1692865162354830955.davem@davemloft.net>
References: <3d1dadb911fa4ebacf1ca5ad298a5c696ed261a6.1461607119.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbcD1Txi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 15:53:38 -0400
In-Reply-To: <3d1dadb911fa4ebacf1ca5ad298a5c696ed261a6.1461607119.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 25 Apr 2016 15:13:17 -0300

> Fix casting in net_gso_ok. Otherwise the shift on
> gso_type << NETIF_F_GSO_SHIFT may hit the 32th bit and make it look like
> a INT_MIN, which is then promoted from signed to uint64 which is
> 0xffffffff80000000, resulting in wrong behavior when it is and'ed with
> the feature itself, as in:
 ...
> So that this:
>    return (features & feature) == feature;
> Actually works on more bits than expected and invalid ones.
> 
> Fix is to promote it earlier.
> 
> Issue noted while rebasing SCTP GSO patch but posting separetely as
> someone else may experience this meanwhile.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Great catch, applied, thanks Marcelo.
