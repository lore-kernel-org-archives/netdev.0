From: domen@coderock.org
Subject: [patch 1/1] net/islpci_dev: replace schedule_timeout() with msleep()
Date: Tue, 11 Jan 2005 23:53:40 +0100
Message-ID: <20050111225341.3AA7E1F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: prism54-private@prism54.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected. Also set_current_state() is
inserted before schedule_timeout().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/prism54/islpci_dev.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev drivers/net/wireless/prism54/islpci_dev.c
--- kj/drivers/net/wireless/prism54/islpci_dev.c~msleep-drivers_net_wireless_prism54_islpci_dev	2005-01-10 18:00:03.000000000 +0100
+++ kj-domen/drivers/net/wireless/prism54/islpci_dev.c	2005-01-10 18:00:03.000000000 +0100
@@ -438,8 +438,7 @@ prism54_bring_down(islpci_private *priv)
 	wmb();
 
 	/* wait a while for the device to reset */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(50*HZ/1000);
+	msleep(50);
 
 	return 0;
 }
_
