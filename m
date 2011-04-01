From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] e1000e: fix stats locking in
	e1000_watchdog_task
Date: Fri,  1 Apr 2011 15:16:04 -0300
Message-ID: <1301681764-25315-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Just move the unlock down a bit because it unlocks too
early leaving a chance for get_stats64() run in parallel
while it is still accessing the stats.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a39d4a4..c19e4f0 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4328,7 +4328,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 link_up:
 	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
-	spin_unlock(&adapter->stats64_lock);
 
 	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
@@ -4339,6 +4338,7 @@ link_up:
 	adapter->gorc_old = adapter->stats.gorc;
 	adapter->gotc = adapter->stats.gotc - adapter->gotc_old;
 	adapter->gotc_old = adapter->stats.gotc;
+	spin_unlock(&adapter->stats64_lock);
 
 	e1000e_update_adaptive(&adapter->hw);
 
-- 
1.7.3.1


------------------------------------------------------------------------------
Create and publish websites with WebMatrix
Use the most popular FREE web apps or write code yourself; 
WebMatrix provides all the features you need to develop and 
publish your website. http://p.sf.net/sfu/ms-webmatrix-sf
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
