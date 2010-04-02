From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-next-2.6 v4 04/14] l2tp: Add ppp device name to L2TP ppp
	session data
Date: Fri, 02 Apr 2010 17:18:44 +0100
Message-ID: <20100402161844.11367.93980.stgit@bert.katalix.com>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:33910 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737Ab0DBQSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 12:18:21 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 2B368A620A3
	for <netdev@vger.kernel.org>; Fri,  2 Apr 2010 17:18:45 +0100 (BST)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XUH2p4kqH6UN for <netdev@vger.kernel.org>;
	Fri,  2 Apr 2010 17:18:44 +0100 (BST)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 2AB98A62087
	for <netdev@vger.kernel.org>; Fri,  2 Apr 2010 17:18:44 +0100 (BST)
In-Reply-To: <20100402161822.11367.70454.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dumping L2TP PPP sessions using /proc/net/pppol2tp, get the
assigned PPP device name from PPP using ppp_dev_name().

Signed-off-by: James Chapman <jchapman@katalix.com>
Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/l2tp/l2tp_ppp.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index baac072..3ad290d 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1465,6 +1465,7 @@ static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
 	struct l2tp_session *session = v;
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct pppol2tp_session *ps = l2tp_session_priv(session);
+	struct pppox_sock *po = pppox_sk(ps->sock);
 	u32 ip = 0;
 	u16 port = 0;
 
@@ -1499,6 +1500,9 @@ static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
 		   (unsigned long long)session->stats.rx_packets,
 		   (unsigned long long)session->stats.rx_bytes,
 		   (unsigned long long)session->stats.rx_errors);
+
+	if (po)
+		seq_printf(m, "   interface %s\n", ppp_dev_name(&po->chan));
 }
 
 static int pppol2tp_seq_show(struct seq_file *m, void *v)

