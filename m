From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] sctp: fix error path in sctp_proc_init
Date: Tue, 17 Jun 2008 16:29:13 +0400
Message-ID: <4857AE19.9050708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60813 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756189AbYFQMbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 08:31:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the sctp_remaddr_proc_init failed, the proper rollback is
not the sctp_remaddr_proc_exit, but the sctp_assocs_proc_exit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 23aaffb..98c6a88 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -119,7 +119,7 @@ static __init int sctp_proc_init(void)
 	return 0;
 
 out_remaddr_proc_init:
-	sctp_remaddr_proc_exit();
+	sctp_assocs_proc_exit();
 out_assocs_proc_init:
 	sctp_eps_proc_exit();
 out_eps_proc_init:
