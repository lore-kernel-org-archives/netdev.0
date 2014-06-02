From: Michal Privoznik <mprivozn@redhat.com>
Subject: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon,  2 Jun 2014 16:25:15 +0200
Message-ID: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link speed is available at /sys/class/net/$nic/speed.
However, the speed is printed in unsigned integer format. This
makes userspace applications read an incorrect value (which
moreover changes through several architectures) while in fact
'-1' should be reported.

Before the change:
  # cat /sys/class/net/eth0/speed
  4294967295

After the change:
  # cat /sys/class/net/eth0/speed
  -1

Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
---
 net/core/net-sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..99afdea 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -173,7 +173,7 @@ static ssize_t speed_show(struct device *dev,
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
 		if (!__ethtool_get_settings(netdev, &cmd))
-			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
+			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
 	}
 	rtnl_unlock();
 	return ret;
-- 
2.0.0
