From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 15:56:47 -0700 (PDT)
Message-ID: <20071005.155647.98545682.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761886AbXJEW4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 18:56:48 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> > +static int __niu_wait_bits_clear(struct niu *np, unsigned long reg,
> > +				 u64 bits, int limit, int delay)
> > +{
> > +	BUILD_BUG_ON(limit <= 0 || delay < 0);
> 
> redundant you already checked

Good catch, fixed!

>From 63f926e5b11d3d03815aeb7bd769e8116a3061fb Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 15:55:55 -0700
Subject: [PATCH] [NIU]: Remove redundant BUILD_BUG_ON() in __niu_wait_bits_clear().

Noticed by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 92059d7..450d95e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -192,7 +192,6 @@ static int __niu_set_and_wait_clear_ipp(struct niu *np, unsigned long reg,
 static int __niu_wait_bits_clear(struct niu *np, unsigned long reg,
 				 u64 bits, int limit, int delay)
 {
-	BUILD_BUG_ON(limit <= 0 || delay < 0);
 	while (--limit >= 0) {
 		u64 val = nr64(reg);
 
-- 
1.5.3.3

