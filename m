From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 02/10] net: add sendmsg_locked and sendpage_locked
 to af_inet6
Date: Tue, 15 Aug 2017 22:31:10 -0700
Message-ID: <20170816053110.15445.5060.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34797 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751731AbdHPFb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:31:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id t86so421618pfe.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:31:28 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To complete the sendmsg_locked and sendpage_locked implementation add
the hooks for af_inet6 as well.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 net/ipv6/af_inet6.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0a7c740..3b58ee7 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -554,6 +554,8 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	.recvmsg	   = inet_recvmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
+	.sendmsg_locked    = tcp_sendmsg_locked,
+	.sendpage_locked   = tcp_sendpage_locked,
 	.splice_read	   = tcp_splice_read,
 	.read_sock	   = tcp_read_sock,
 	.peek_len	   = tcp_peek_len,
