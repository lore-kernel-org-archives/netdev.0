From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net] selinux: nlmsgtab: add SOCK_DESTROY to the netlink mapping tables
Date: Thu,  4 Feb 2016 01:17:12 +0900
Message-ID: <1454516232-18546-1-git-send-email-lorenzo@google.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35359 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbcBCQRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 11:17:18 -0500
Received: by mail-pa0-f49.google.com with SMTP id ho8so15719322pac.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 08:17:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this, using SOCK_DESTROY in enforcing mode results in:

  SELinux: unrecognized netlink message type=21 for sclass=32

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 2bbb418..8495b93 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -83,6 +83,7 @@ static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
 	{ TCPDIAG_GETSOCK,	NETLINK_TCPDIAG_SOCKET__NLMSG_READ },
 	{ DCCPDIAG_GETSOCK,	NETLINK_TCPDIAG_SOCKET__NLMSG_READ },
 	{ SOCK_DIAG_BY_FAMILY,	NETLINK_TCPDIAG_SOCKET__NLMSG_READ },
+	{ SOCK_DESTROY,		NETLINK_TCPDIAG_SOCKET__NLMSG_WRITE },
 };
 
 static struct nlmsg_perm nlmsg_xfrm_perms[] =
-- 
2.7.0.rc3.207.g0ac5344
