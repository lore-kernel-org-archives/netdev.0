From: domen@coderock.org
Subject: [patch 15/26] net/skethtool: remove duplicate delay
Date: Sun, 06 Mar 2005 11:33:25 +0100
Message-ID: <20050306103325.B5BDF1F205@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Please consider applying. 

Remove an unnecessary second (and identical) delay.
schedule_timeout() does not need to be called, as msleep_interruptible() already
delayed the task.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/sk98lin/skethtool.c |    3 ---
 1 files changed, 3 deletions(-)

diff -puN drivers/net/sk98lin/skethtool.c~remove_duplicate_delay-drivers_net_sk98lin_skethtool drivers/net/sk98lin/skethtool.c
--- kj/drivers/net/sk98lin/skethtool.c~remove_duplicate_delay-drivers_net_sk98lin_skethtool	2005-03-05 16:11:09.000000000 +0100
+++ kj-domen/drivers/net/sk98lin/skethtool.c	2005-03-05 16:11:09.000000000 +0100
@@ -437,9 +437,6 @@ static int locateDevice(struct net_devic
 	pAC->LedsOn = 0;
 	mod_timer(&pAC->BlinkTimer, jiffies);
 	msleep_interruptible(data * 1000);
-
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(data * HZ);
 	del_timer_sync(&pAC->BlinkTimer);
 	toggleLeds(pNet, 0);
 
_
