From: akpm@linux-foundation.org
Subject: [patch 01/17] drivers/net/mv643xx_eth.c: Use FIELD_SIZEOF
Date: Tue, 04 Mar 2008 15:19:19 -0800
Message-ID: <200803042319.m24NJK7X002654@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50820 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935069AbYCDXT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Robert P.J. Day proposed to use the macro FIELD_SIZEOF in replace of code
that matches its definition.

The modification was made using the following semantic patch
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@haskernel@
@@

#include <linux/kernel.h>

@depends on haskernel@
type t;
identifier f;
@@

- (sizeof(((t*)0)->f))
+ FIELD_SIZEOF(t, f)

@depends on haskernel@
type t;
identifier f;
@@

- sizeof(((t*)0)->f)
+ FIELD_SIZEOF(t, f)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/mv643xx_eth.c~drivers-net-mv643xx_ethc-use-field_sizeof drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c~drivers-net-mv643xx_ethc-use-field_sizeof
+++ a/drivers/net/mv643xx_eth.c
@@ -3155,7 +3155,7 @@ struct mv643xx_stats {
 	int stat_offset;
 };
 
-#define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
+#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
 					offsetof(struct mv643xx_private, m)
 
 static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
_
