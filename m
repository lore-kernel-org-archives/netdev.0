From: Alan <gnomes@lxorguk.ukuu.org.uk>
Subject: [PATCH] af_llc: fix types on llc_ui_wait_for_conn
Date: Mon, 15 Feb 2016 19:02:02 +0000
Message-ID: <20160215190200.11338.84808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:44872 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbcBOTCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 14:02:09 -0500
Received: from localhost.localdomain (proxy [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.15.2/8.14.1) with ESMTP id u1FJbdeW010043
	for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 19:37:44 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timeout is a long, we return it truncated if it is huge. Basically
harmless as the only caller does a boolean check, but tidy it up anyway.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---
 net/llc/af_llc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8dab4e5..f05a2cb 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -551,7 +551,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
 	return rc;
 }
 
-static int llc_ui_wait_for_conn(struct sock *sk, long timeout)
+static long llc_ui_wait_for_conn(struct sock *sk, long timeout)
 {
 	DEFINE_WAIT(wait);
 
