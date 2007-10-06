From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 17:04:28 -0700 (PDT)
Message-ID: <20071005.170428.68050176.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005084317.52ee7efe@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761872AbXJFAE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:04:29 -0400
In-Reply-To: <20071005084317.52ee7efe@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:43:17 -0700

> Sparse warnings from new driver.
>  CHECK   drivers/net/niu.c
> drivers/net/niu.c:619:7: warning: symbol 'err' shadows an earlier one
> drivers/net/niu.c:574:6: originally declared here
> drivers/net/niu.c:4673:7: warning: symbol 'err' shadows an earlier one
> drivers/net/niu.c:4668:12: originally declared here

I fixed these two, the first was harmless but the second
one would cause error cases to return the wrong error
status to the caller.

> drivers/net/niu.c:203:2: error: bad constant expression
> drivers/net/niu.c:203:2: error: cannot size expression
> drivers/net/niu.c:4214:2: error: bad constant expression
> drivers/net/niu.c:4214:2: error: cannot size expression

I can't figure out what sparse doesn't like here.

Thanks.

>From 81d1d30537ae388a9ee385d0640999195967b905 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 17:03:19 -0700
Subject: [PATCH] [NIU]: Fix shadowed local variables.

Noticed by sparse.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index da15a91..64b988b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -607,7 +607,6 @@ static int serdes_init_10g(struct niu *np)
 
 	for (i = 0; i < 4; i++) {
 		u32 rxtx_ctrl, glue0;
-		int err;
 
 		err = esr_read_rxtx_ctrl(np, i, &rxtx_ctrl);
 		if (err)
@@ -4657,7 +4656,6 @@ static int niu_request_irq(struct niu *np)
 	err = 0;
 	for (i = 0; i < np->num_ldg; i++) {
 		struct niu_ldg *lp = &np->ldg[i];
-		int err;
 
 		err = request_irq(lp->irq, niu_interrupt,
 				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-- 
1.5.3.3

