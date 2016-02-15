From: Alan <gnomes@lxorguk.ukuu.org.uk>
Subject: [PATCHv2] af_llc: fix types on llc_ui_wait_for_conn
Date: Mon, 15 Feb 2016 19:41:51 +0000
Message-ID: <20160215194129.18888.95792.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:45178 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbcBOTl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 14:41:58 -0500
Received: from localhost.localdomain (proxy [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.15.2/8.14.1) with ESMTP id u1FKHStu010804
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 20:17:33 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timeout is a long, we return it truncated if it is huge. Basically
harmless as the only caller does a boolean check, but tidy it up anyway.

(64bit build tested this time. Thank you 0day)

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 net/llc/af_llc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8dab4e5..b3c52e3 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -38,7 +38,7 @@ static u16 llc_ui_sap_link_no_max[256];
 static struct sockaddr_llc llc_ui_addrnull;
 static const struct proto_ops llc_ui_ops;
 
-static int llc_ui_wait_for_conn(struct sock *sk, long timeout);
+static long llc_ui_wait_for_conn(struct sock *sk, long timeout);
 static int llc_ui_wait_for_disc(struct sock *sk, long timeout);
 static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout);
 
@@ -551,7 +551,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
 	return rc;
 }
 
-static int llc_ui_wait_for_conn(struct sock *sk, long timeout)
+static long llc_ui_wait_for_conn(struct sock *sk, long timeout)
 {
 	DEFINE_WAIT(wait);
 
