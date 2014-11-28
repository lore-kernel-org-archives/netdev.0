From: roy.qing.li@gmail.com
Subject: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit userspace
Date: Fri, 28 Nov 2014 14:58:56 +0800
Message-ID: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56859 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbaK1G7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 01:59:03 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so6255794pad.31
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 22:59:02 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id qf1sm8918687pdb.49.2014.11.27.22.59.01
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Nov 2014 22:59:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kernel, and
164 bytes for 32bit userspace because of the different alignment. and lead
to "ip xfrm" be unable to work.

add a pad in struct xfrm_userpolicy_info, and enable it by set
KERNEL_64_USERSPACE_32 to y

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 Makefile             | 4 ++++
 include/linux/xfrm.h | 3 +++
 2 files changed, 7 insertions(+)

diff --git a/Makefile b/Makefile
index 9dbb29f..3cd0d67 100644
--- a/Makefile
+++ b/Makefile
@@ -18,6 +18,10 @@ ifneq ($(SHARED_LIBS),y)
 DEFINES+= -DNO_SHARED_LIBS
 endif
 
+ifeq ($(KERNEL_64_USERSPACE_32),y)
+DEFINES+= -DKNL_64_US_32
+endif
+
 DEFINES+=-DCONFDIR=\"$(CONFDIR)\"
 
 #options for decnet
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index fa2ecb2..009510c 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -407,6 +407,9 @@ struct xfrm_userpolicy_info {
 	/* Automatically expand selector to include matching ICMP payloads. */
 #define XFRM_POLICY_ICMP	2
 	__u8				share;
+#ifdef KNL_64_US_32
+	int				pad;
+#endif
 };
 
 struct xfrm_userpolicy_id {
-- 
2.1.0
