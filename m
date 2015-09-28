From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH v2 1/1] net sysfs: Print link speed as signed integer
Date: Mon, 28 Sep 2015 15:05:33 +0200
Message-ID: <1443445533-14474-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Otherwise 4294967295 (MBit/s) (-1) will be printed when there is no link.
Documentation/ABI/testing/sysfs-class-net does not state if this shall be
signed or unsigned.
Also remove the now unused variable fmt_udec.

Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
Changes in v2:
* Switch the format specifier instead of changing it
* Remove the now unused variable

 net/core/net-sysfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 805a95a..830f8a7 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -31,7 +31,6 @@
 static const char fmt_hex[] = "%#x\n";
 static const char fmt_long_hex[] = "%#lx\n";
 static const char fmt_dec[] = "%d\n";
-static const char fmt_udec[] = "%u\n";
 static const char fmt_ulong[] = "%lu\n";
 static const char fmt_u64[] = "%llu\n";
 
@@ -202,7 +201,7 @@ static ssize_t speed_show(struct device *dev,
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
 		if (!__ethtool_get_settings(netdev, &cmd))
-			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
+			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
 	}
 	rtnl_unlock();
 	return ret;
-- 
2.4.9
