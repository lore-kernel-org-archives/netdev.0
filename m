From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next] ipv6: sr: add missing Kbuild export for header files
Date: Fri, 13 Jan 2017 10:26:04 +0100
Message-ID: <1484299564-6165-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33489 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751286AbdAMJZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 04:25:31 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id A6A0167DDA4
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 10:25:04 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing IPv6-SR header files in include/uapi/linux/Kbuild.

Also, prevent seg6_lwt_headroom() from being exported.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/uapi/linux/Kbuild          | 4 ++++
 include/uapi/linux/seg6_iptunnel.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index f330ba4..e600b50 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -379,6 +379,10 @@ header-y += sctp.h
 header-y += sdla.h
 header-y += seccomp.h
 header-y += securebits.h
+header-y += seg6_genl.h
+header-y += seg6.h
+header-y += seg6_hmac.h
+header-y += seg6_iptunnel.h
 header-y += selinux_netlink.h
 header-y += sem.h
 header-y += serial_core.h
diff --git a/include/uapi/linux/seg6_iptunnel.h b/include/uapi/linux/seg6_iptunnel.h
index 0f7dbd2..7a7183d 100644
--- a/include/uapi/linux/seg6_iptunnel.h
+++ b/include/uapi/linux/seg6_iptunnel.h
@@ -33,6 +33,8 @@ enum {
 	SEG6_IPTUN_MODE_ENCAP,
 };
 
+#ifdef __KERNEL__
+
 static inline size_t seg6_lwt_headroom(struct seg6_iptunnel_encap *tuninfo)
 {
 	int encap = (tuninfo->mode == SEG6_IPTUN_MODE_ENCAP);
@@ -42,3 +44,5 @@ static inline size_t seg6_lwt_headroom(struct seg6_iptunnel_encap *tuninfo)
 }
 
 #endif
+
+#endif
-- 
2.7.3
