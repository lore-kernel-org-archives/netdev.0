From: domen@coderock.org
Subject: [patch 12/19] net/ixgb_ethtool: replace schedule_timeout() with msleep_interruptible()
Date: Wed, 12 Jan 2005 00:10:43 +0100
Message-ID: <20050111231044.19A741F231@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of 
schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/ixgb/ixgb_ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ixgb/ixgb_ethtool.c~msleep_interruptible-drivers_net_ixgb_ixgb_ethtool drivers/net/ixgb/ixgb_ethtool.c
--- kj/drivers/net/ixgb/ixgb_ethtool.c~msleep_interruptible-drivers_net_ixgb_ixgb_ethtool	2005-01-10 18:00:06.000000000 +0100
+++ kj-domen/drivers/net/ixgb/ixgb_ethtool.c	2005-01-10 18:00:06.000000000 +0100
@@ -404,9 +404,9 @@ ixgb_ethtool_led_blink(struct net_device
 
 	set_current_state(TASK_INTERRUPTIBLE);
 	if (data)
-		schedule_timeout(data * HZ);
+		msleep_interruptible(data * 1000);
 	else
-		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
+		msleep_interruptible(jiffies_to_msecs(MAX_SCHEDULE_TIMEOUT));
 
 	del_timer_sync(&adapter->blink_timer);
 	ixgb_led_off(&adapter->hw);
_
