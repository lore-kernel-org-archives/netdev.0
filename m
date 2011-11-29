From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] enic: Use kcalloc instead of kzalloc to allocate array
Date: Tue, 29 Nov 2011 22:08:00 +0100
Message-ID: <1322600880.1534.321.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
--- a/drivers/net/ethernet/cisco/enic/enic_main.c 2011-11-13 11:07:34.306945516 +0100
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c 2011-11-28 19:53:11.983614560 +0100
@@ -2379,7 +2379,7 @@ static int __devinit enic_probe(struct p
 
 #endif
 	/* Allocate structure for port profiles */
-	enic->pp = kzalloc(num_pps * sizeof(*enic->pp), GFP_KERNEL);
+	enic->pp = kcalloc(num_pps, sizeof(*enic->pp), GFP_KERNEL);
 	if (!enic->pp) {
 		pr_err("port profile alloc failed, aborting\n");
 		err = -ENOMEM;
