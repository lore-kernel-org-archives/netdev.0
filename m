From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] netlink: remove duplicated NLMSG_ALIGN
Date: Tue, 26 Mar 2013 13:04:05 +0800
Message-ID: <1364274245-20689-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	zhiguo.hong@emc.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:41250 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab3CZFER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 01:04:17 -0400
Received: by mail-da0-f48.google.com with SMTP id p8so3482817dan.7
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 22:04:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NLMSG_HDRLEN is already aligned value. It's for directly reference
without extra alignment.

The redundant alignment here may confuse the API users.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 include/uapi/linux/netlink.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 78d5b8a..32a354f 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -78,7 +78,7 @@ struct nlmsghdr {
 #define NLMSG_ALIGNTO	4U
 #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
 #define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
-#define NLMSG_LENGTH(len) ((len)+NLMSG_ALIGN(NLMSG_HDRLEN))
+#define NLMSG_LENGTH(len) ((len) + NLMSG_HDRLEN)
 #define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
 #define NLMSG_DATA(nlh)  ((void*)(((char*)nlh) + NLMSG_LENGTH(0)))
 #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
-- 
1.7.10.4
