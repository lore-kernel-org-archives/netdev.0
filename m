From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IRDA] Move ircomm_tty_line_info() under #ifdef CONFIG_PROC_FS
Date: Tue, 04 Dec 2007 18:14:48 +0300
Message-ID: <47556EE8.1000605@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>, irda-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55797 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801AbXLDPRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 10:17:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function in question is called only from ircomm_tty_read_proc,
which is under this option. Move this helper to the same place.

Fits both net-2.6 and net-2.6.25

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 1120b15..be627e1 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -1245,6 +1245,7 @@ static void ircomm_tty_flow_indication(void *instance, void *sap,
 	self->flow = cmd;
 }
 
+#ifdef CONFIG_PROC_FS
 static int ircomm_tty_line_info(struct ircomm_tty_cb *self, char *buf)
 {
 	int  ret=0;
@@ -1354,7 +1355,6 @@ static int ircomm_tty_line_info(struct ircomm_tty_cb *self, char *buf)
  *
  *
  */
-#ifdef CONFIG_PROC_FS
 static int ircomm_tty_read_proc(char *buf, char **start, off_t offset, int len,
 				int *eof, void *unused)
 {
-- 
1.5.3.4

