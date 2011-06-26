From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 02/12] NET: 3c509: Fix section mismatch
Date: Sun, 26 Jun 2011 12:21:31 +0100
Message-ID: <ab495fabda7fe6b70a76e5592fb3a0c1180b325b.1309182743.git.ralf@linux-mips.org>
References: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:40646 "EHLO duck.linux-mips.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750994Ab1F0PiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 11:38:05 -0400
In-Reply-To: <17dd5038b15d7135791aadbe80464a13c80758d3.1309182742.git.ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: drivers/net/3c509.o(.data+0x190): Section mismatch in reference from the variable el3_eisa_driver to the function .init.text:el3_eisa_probe()
The variable el3_eisa_driver references
the function __init el3_eisa_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
---
 drivers/net/3c509.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 44b28b2..dc4bf07 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -671,7 +671,7 @@ static int __init el3_mca_probe(struct device *device)
 #endif /* CONFIG_MCA */
 
 #ifdef CONFIG_EISA
-static int __init el3_eisa_probe (struct device *device)
+static int __devinit el3_eisa_probe(struct device *device)
 {
 	short i;
 	int ioaddr, irq, if_port;
-- 
1.7.4.4

