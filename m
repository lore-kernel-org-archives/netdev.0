From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix result of sh_eth_check_reset() on timeout
Date: Wed, 5 Jun 2013 23:54:01 +0400
Message-ID: <201306052354.02265.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When  the first loop in sh_eth_check_reset() runs to its end, 'cnt' is 0, so the
following check for 'cnt < 0' fails to catch the timeout.  Fix the  condition in
this check, so that the timeout  is actually reported.
While at it, fix the grammar in the failure message...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the David Miller's 'net.git' repo.
Dave, since this is fixing the failure case, I don't think it's needed in
-stable...

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -897,8 +897,8 @@ static int sh_eth_check_reset(struct net
 		mdelay(1);
 		cnt--;
 	}
-	if (cnt < 0) {
-		pr_err("Device reset fail\n");
+	if (cnt <= 0) {
+		pr_err("Device reset failed\n");
 		ret = -ETIMEDOUT;
 	}
 	return ret;
