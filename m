From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/9] drivers/net: Eliminate useless code
Date: Sat, 16 Jan 2010 16:57:56 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1001161657400.28745@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:42631 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753542Ab0APP56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jan 2010 10:57:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

The variable qdev is initialized twice to the same (side effect-free)
expression.  Drop one initialization.

A simplified version of the semantic match that finds this problem is:
(http://coccinelle.lip6.fr/)

// <smpl>
@forall@
idexpression *x;
identifier f!=ERR_PTR;
@@

x = f(...)
... when != x
(
x = f(...,<+...x...+>,...)
|
* x = f(...)
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/qla3xxx.c               |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index f922294..4ef0afb 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -4087,9 +4087,8 @@ static void __devexit ql3xxx_remove(struct pci_dev *pdev)
 	struct ql3_adapter *qdev = netdev_priv(ndev);
 
 	unregister_netdev(ndev);
-	qdev = netdev_priv(ndev);
 
 	ql_disable_interrupts(qdev);
 
