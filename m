From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 10/14] ipw2200: Fix kernel Oops if cmdlog debug is enabled
Date: Mon, 21 Aug 2006 11:38:28 +0800
Message-ID: <20060821033828.GA5407@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10576 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932588AbWHUDkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:22 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When command error log debug is enabled, we write every host command and
parameters into a buffer. But we didn't alloc the parameter buffer for this
case. The patch adds struct cmdlog_host_cmd so that the buffer is allocated
from the stack.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.h |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

b1822c22dbc0bd552b41f714ce38324325ecd8a5
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 32b4ef8..a1df67f 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1950,10 +1950,17 @@ struct host_cmd {
 	u32 *param;
 } __attribute__ ((packed));
 
+struct cmdlog_host_cmd {
+	u8 cmd;
+	u8 len;
+	u16 reserved;
+	char param[124];
+} __attribute__ ((packed));
+
 struct ipw_cmd_log {
 	unsigned long jiffies;
 	int retcode;
-	struct host_cmd cmd;
+	struct cmdlog_host_cmd cmd;
 };
 
 /* SysConfig command parameters ... */
-- 
1.2.6
