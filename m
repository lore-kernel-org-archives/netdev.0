From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/3][NETLABLE]: Hide netlbl_unlabel_audit_addr6 under ifdef
 CONFIG_IPV6.
Date: Thu, 07 Feb 2008 20:25:52 +0300
Message-ID: <47AB3F20.2030809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50455 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693AbYBGRZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 12:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is called from under this config only, so move
it in the same place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/netlabel/netlabel_unlabeled.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 3587874..3e745b7 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -180,6 +180,7 @@ static void netlbl_unlabel_audit_addr4(struct audit_buffer *audit_buf,
 	}
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 /**
  * netlbl_unlabel_audit_addr6 - Audit an IPv6 address
  * @audit_buf: audit buffer
@@ -213,6 +214,7 @@ static void netlbl_unlabel_audit_addr6(struct audit_buffer *audit_buf,
 		audit_log_format(audit_buf, " src_prefixlen=%d", mask_len);
 	}
 }
+#endif /* IPv6 */
 
 /*
  * Unlabeled Connection Hash Table Functions
-- 
1.5.3.4

