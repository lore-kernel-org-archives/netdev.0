From: weiyj_lk@163.com
Subject: [PATCH -next] tipc: fix sparse non static symbol warnings
Date: Sun, 20 Jul 2014 13:14:28 +0800
Message-ID: <1405833268-6630-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:34683 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaGTFPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 01:15:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warnings:

net/tipc/socket.c:545:5: warning:
 symbol 'tipc_sk_proto_rcv' was not declared. Should it be static?
net/tipc/socket.c:2015:5: warning:
 symbol 'tipc_ioctl' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/tipc/socket.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index de01622..42c3599 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -542,7 +542,8 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
  * Returns 0 (TIPC_OK) if message was consumed, 1 (TIPC_FWD_MSG) if
  * (CONN_PROBE_REPLY) message should be forwarded.
  */
-int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode, struct sk_buff *buf)
+static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
+			     struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_port *port = &tsk->port;
@@ -2012,7 +2013,7 @@ static int tipc_getsockopt(struct socket *sock, int lvl, int opt,
 	return put_user(sizeof(value), ol);
 }
 
-int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
+static int tipc_ioctl(struct socket *sk, unsigned int cmd, unsigned long arg)
 {
 	struct tipc_sioc_ln_req lnr;
 	void __user *argp = (void __user *)arg;
