From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 01/28] phc: Add a method for
	obtaining the device index.
Date: Sun,  1 Apr 2012 17:19:46 +0200
Message-ID: <c80e9d0be719eccf7044d3fe4fbf1ef1d7907dc9.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This commit adds a method that MAC drivers may call in order to find out
the device number of their associated PTP Hardware Clock.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c          |    6 ++++++
 include/linux/ptp_clock_kernel.h |    8 ++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index f519a13..1e528b5 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -304,6 +304,12 @@ void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *event)
 }
 EXPORT_SYMBOL(ptp_clock_event);
 
+int ptp_clock_index(struct ptp_clock *ptp)
+{
+	return ptp->index;
+}
+EXPORT_SYMBOL(ptp_clock_index);
+
 /* module operations */
 
 static void __exit ptp_exit(void)
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index dd2e44f..945704c 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -136,4 +136,12 @@ struct ptp_clock_event {
 extern void ptp_clock_event(struct ptp_clock *ptp,
 			    struct ptp_clock_event *event);
 
+/**
+ * ptp_clock_index() - obtain the device index of a PTP clock
+ *
+ * @ptp:    The clock obtained from ptp_clock_register().
+ */
+
+extern int ptp_clock_index(struct ptp_clock *ptp);
+
 #endif
-- 
1.7.2.5


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
