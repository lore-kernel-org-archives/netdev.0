From: Dave Jones <davej@redhat.com>
Subject: Remove noisy printks from llcp_sock_connect
Date: Thu, 4 Oct 2012 15:51:11 -0400
Message-ID: <20121004195111.GA31119@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757346Ab2JDTvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 15:51:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Validation of userspace input shouldn't trigger dmesg spamming.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 40f056d..63e4cdc 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -497,15 +497,11 @@ static int llcp_sock_connect(struct socket *sock, struct sockaddr *_addr,
 	pr_debug("sock %p sk %p flags 0x%x\n", sock, sk, flags);
 
 	if (!addr || len < sizeof(struct sockaddr_nfc) ||
-	    addr->sa_family != AF_NFC) {
-		pr_err("Invalid socket\n");
+	    addr->sa_family != AF_NFC)
 		return -EINVAL;
-	}
 
-	if (addr->service_name_len == 0 && addr->dsap == 0) {
-		pr_err("Missing service name or dsap\n");
+	if (addr->service_name_len == 0 && addr->dsap == 0)
 		return -EINVAL;
-	}
 
 	pr_debug("addr dev_idx=%u target_idx=%u protocol=%u\n", addr->dev_idx,
 		 addr->target_idx, addr->nfc_protocol);
