From: domen@coderock.org
Subject: [patch 12/26] net/farsync: add set_current_state() before schedule_timeout()
Date: Sun, 06 Mar 2005 11:33:15 +0100
Message-ID: <20050306103315.B504E1F204@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Insert set_current_state() before schedule_timeout() so the
function delays as expected. Without the addition, schedule_timeout()
will return immediately.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wan/farsync.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/wan/farsync.c~set_current_state-drivers_net_wan_farsync drivers/net/wan/farsync.c
--- kj/drivers/net/wan/farsync.c~set_current_state-drivers_net_wan_farsync	2005-03-05 16:09:48.000000000 +0100
+++ kj-domen/drivers/net/wan/farsync.c	2005-03-05 16:09:48.000000000 +0100
@@ -981,6 +981,7 @@ fst_issue_cmd(struct fst_port_info *port
 	/* Wait for any previous command to complete */
 	while (mbval > NAK) {
 		spin_unlock_irqrestore(&card->card_lock, flags);
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(1);
 		spin_lock_irqsave(&card->card_lock, flags);
 
_
