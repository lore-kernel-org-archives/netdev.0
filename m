From: domen@coderock.org
Subject: [patch 1/3] net/islpci_dev: replace schedule_timeout() with msleep()
Date: Sun, 06 Mar 2005 23:23:51 +0100
Message-ID: <20050306222352.514491EC90@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
To: prism54-private@prism54.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected. Also set_current_state() is
inserted before schedule_timeout().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/prism54/islpci_dev.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev drivers/net/wireless/prism54/islpci_dev.c
--- kj/drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev	2005-03-05 16:09:30.000000000 +0100
+++ kj-domen/drivers/net/wireless/prism54/islpci_dev.c	2005-03-05 16:09:30.000000000 +0100
@@ -438,8 +438,7 @@ prism54_bring_down(islpci_private *priv)
 	wmb();
 
 	/* wait a while for the device to reset */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(50*HZ/1000);
+	msleep(50);
 
 	return 0;
 }
_
