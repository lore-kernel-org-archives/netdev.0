From: janitor@sternwelten.at
Subject: [patch 07/18]  net/islpci_dev: replace 	schedule_timeout() with msleep()
Date: Sun, 31 Oct 2004 00:42:39 +0200
Message-ID: <E1CO1vk-0002Be-1K@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected. Also set_current_state() is
inserted before schedule_timeout(). If the for-loop were to execute
twice, the second time would not set the state before sleeping in the
current code; this causes schedule_timeout() to return immediately.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/wireless/prism54/islpci_dev.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.10-rc1/drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev	2004-10-24 17:05:03.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/wireless/prism54/islpci_dev.c	2004-10-24 17:05:03.000000000 +0200
@@ -438,8 +438,7 @@ prism54_bring_down(islpci_private *priv)
 	wmb();
 
 	/* wait a while for the device to reset */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(50*HZ/1000);
+	msleep(50);
 
 	return 0;
 }
_
