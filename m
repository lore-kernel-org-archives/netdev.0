From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] pptp: verify sockaddr_len in pptp_bind() and pptp_connect()
Date: Mon, 14 Dec 2015 13:48:36 -0800
Message-ID: <1450129716-32422-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36707 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbbLNVzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:55:54 -0500
Received: by pfbu66 with SMTP id u66so67866707pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 13:55:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Dmitry Vyukov <dvyukov@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ppp/pptp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index fc69e41..597c53e 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -419,6 +419,9 @@ static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr,
 	struct pptp_opt *opt = &po->proto.pptp;
 	int error = 0;
 
+	if (sockaddr_len < sizeof(struct sockaddr_pppox))
+		return -EINVAL;
+
 	lock_sock(sk);
 
 	opt->src_addr = sp->sa_addr.pptp;
@@ -440,6 +443,9 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	struct flowi4 fl4;
 	int error = 0;
 
+	if (sockaddr_len < sizeof(struct sockaddr_pppox))
+		return -EINVAL;
+
 	if (sp->sa_protocol != PX_PROTO_PPTP)
 		return -EINVAL;
 
-- 
1.8.3.1
