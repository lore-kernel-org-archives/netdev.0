From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 8/8][ATM]: [speedtch] cure atm_printk() macro gcc-2.95 compile error
Date: Tue, 19 Jul 2005 16:47:42 -0400
Message-ID: <200507192047.j6JKle4w027287@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [speedtch] cure atm_printk() macro gcc-2.95 compile error

  Signed-off-by: Duncan Sands <baldrick@free.fr>
  Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit 73500df545c8763d662192d9749fd8d64209c819
tree 0f73d33200e626e8ef0af506dbed40a3850c609b
parent 4932248439d20412610ffaade625cbde0e001e37
author chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:22:52 -0400
committer chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:22:52 -0400

 drivers/usb/atm/speedtch.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/atm/speedtch.c b/drivers/usb/atm/speedtch.c
--- a/drivers/usb/atm/speedtch.c
+++ b/drivers/usb/atm/speedtch.c
@@ -448,19 +448,19 @@ static void speedtch_check_status(struct
 		case 0:
 			atm_dev->signal = ATM_PHY_SIG_LOST;
 			if (instance->last_status)
-				atm_info(usbatm, "ADSL line is down\n");
+				atm_info(usbatm, "%s\n", "ADSL line is down");
 			/* It may never resync again unless we ask it to... */
 			ret = speedtch_start_synchro(instance);
 			break;
 
 		case 0x08:
 			atm_dev->signal = ATM_PHY_SIG_UNKNOWN;
-			atm_info(usbatm, "ADSL line is blocked?\n");
+			atm_info(usbatm, "%s\n", "ADSL line is blocked?");
 			break;
 
 		case 0x10:
 			atm_dev->signal = ATM_PHY_SIG_LOST;
-			atm_info(usbatm, "ADSL line is synchronising\n");
+			atm_info(usbatm, "%s\n", "ADSL line is synchronising");
 			break;
 
 		case 0x20:
@@ -502,7 +502,7 @@ static void speedtch_status_poll(unsigne
 	if (instance->poll_delay < MAX_POLL_DELAY)
 		mod_timer(&instance->status_checker.timer, jiffies + msecs_to_jiffies(instance->poll_delay));
 	else
-		atm_warn(instance->usbatm, "Too many failures - disabling line status polling\n");
+		atm_warn(instance->usbatm, "%s\n", "Too many failures - disabling line status polling");
 }
 
 static void speedtch_resubmit_int(unsigned long data)
@@ -545,9 +545,9 @@ static void speedtch_handle_int(struct u
 
 	if ((count == 6) && !memcmp(up_int, instance->int_data, 6)) {
 		del_timer(&instance->status_checker.timer);
-		atm_info(usbatm, "DSL line goes up\n");
+		atm_info(usbatm, "%s\n", "DSL line goes up");
 	} else if ((count == 6) && !memcmp(down_int, instance->int_data, 6)) {
-		atm_info(usbatm, "DSL line goes down\n");
+		atm_info(usbatm, "%s\n", "DSL line goes down");
 	} else {
 		int i;
 
