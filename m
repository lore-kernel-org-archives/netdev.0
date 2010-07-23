From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH 2/5] drivers: net: use newly introduced hex_to_bin()
Date: Fri, 23 Jul 2010 16:18:07 +0300
Message-ID: <3f9b9040fd8614141d4d7df59fbccf32d50e997d.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
In-Reply-To: <cover.1279890832.git.andy.shevchenko@gmail.com>
References: <cover.1279890832.git.andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/ksz884x.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 1d998e1..37504a3 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -6894,13 +6894,12 @@ static void get_mac_addr(struct dev_info *hw_priv, u8 *macaddr, int port)
 	i = j = num = got_num = 0;
 	while (j < MAC_ADDR_LEN) {
 		if (macaddr[i]) {
+			int digit;
+
 			got_num = 1;
-			if ('0' <= macaddr[i] && macaddr[i] <= '9')
-				num = num * 16 + macaddr[i] - '0';
-			else if ('A' <= macaddr[i] && macaddr[i] <= 'F')
-				num = num * 16 + 10 + macaddr[i] - 'A';
-			else if ('a' <= macaddr[i] && macaddr[i] <= 'f')
-				num = num * 16 + 10 + macaddr[i] - 'a';
+			digit = hex_to_bin(macaddr[i]);
+			if (digit >= 0)
+				num = num * 16 + digit;
 			else if (':' == macaddr[i])
 				got_num = 2;
 			else
-- 
1.7.1.1
