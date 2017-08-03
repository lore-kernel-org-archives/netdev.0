From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 2/6] net: add sendmsg_locked and sendpage_locked to
 af_inet6
Date: Thu, 03 Aug 2017 16:37:14 -0700
Message-ID: <20170803233714.12107.63167.stgit@john-Precision-Tower-5810>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33908 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdHCXha (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:37:30 -0400
Received: by mail-pg0-f66.google.com with SMTP id y192so152022pgd.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:37:30 -0700 (PDT)
In-Reply-To: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
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
