From: domen@coderock.org
Subject: [patch 1/1] net/farsync: add set_current_state() before schedule_timeout()
Date: Wed, 12 Jan 2005 00:07:43 +0100
Message-ID: <20050111230744.403911F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: kevin.curtis@farsite.co.uk
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Insert set_current_state() before schedule_timeout() so the
function delays as expected. Without the addition, schedule_timeout()
will return immediately.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wan/farsync.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/wan/farsync.c~set_current_state-drivers_net_wan_farsync drivers/net/wan/farsync.c
--- kj/drivers/net/wan/farsync.c~set_current_state-drivers_net_wan_farsync	2005-01-10 18:00:19.000000000 +0100
+++ kj-domen/drivers/net/wan/farsync.c	2005-01-10 18:00:19.000000000 +0100
@@ -981,6 +981,7 @@ fst_issue_cmd(struct fst_port_info *port
 	/* Wait for any previous command to complete */
 	while (mbval > NAK) {
 		spin_unlock_irqrestore(&card->card_lock, flags);
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout(1);
 		spin_lock_irqsave(&card->card_lock, flags);
 
_
