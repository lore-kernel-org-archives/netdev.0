From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix crash in XFRM_MSG_GETSA netlink handler
Date: Tue, 05 Jul 2016 12:13:03 -0700 (PDT)
Message-ID: <20160705.121303.399318377900246102.davem@davemloft.net>
References: <1467706688-3631-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcGETNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:13:06 -0400
In-Reply-To: <1467706688-3631-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Tue,  5 Jul 2016 10:18:08 +0200

> If we hit any of the error conditions inside xfrm_dump_sa(), then
> xfrm_state_walk_init() never gets called. However, we still call
> xfrm_state_walk_done() from xfrm_dump_sa_done(), which will crash
> because the state walk was never initialized properly.
> 
> We can fix this by setting cb->args[0] only after we've processed the
> first element and checking this before calling xfrm_state_walk_done().
> 
> Fixes: d3623099d3 ("ipsec: add support of limited SA dump")
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

I assume Steffen will pick this up.
