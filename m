From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 05/43] drivers/net/niu.c: fix sparse warning: symbol shadows
	an earlier one
Date: Sat, 14 Feb 2009 22:12:48 +0100
Message-ID: <20090214211244.23489.31564.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:48565 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbZBNVMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:12:54 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Move variable declaration to a more inner scope.

Fix this sparse warning:
  drivers/net/niu.c:2399:21: warning: symbol 'err' shadows an earlier one
  drivers/net/niu.c:2287:13: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index c26325d..32374a1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -2284,7 +2284,6 @@ static int serdes_init_10g_serdes(struct niu *np)
 	struct niu_link_config *lp = &np->link_config;
 	unsigned long ctrl_reg, test_cfg_reg, pll_cfg, i;
 	u64 ctrl_val, test_cfg_val, sig, mask, val;
-	int err;
 	u64 reset_val;
 
 	switch (np->port) {
@@ -2337,6 +2336,7 @@ static int serdes_init_10g_serdes(struct niu *np)
 	/* Initialize all 4 lanes of the SERDES.  */
 	for (i = 0; i < 4; i++) {
 		u32 rxtx_ctrl, glue0;
+		int err;
 
 		err = esr_read_rxtx_ctrl(np, i, &rxtx_ctrl);
 		if (err)

