From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH[ (6/15) atm -- size_t in send/recvmsg
Date: Fri, 9 Jan 2004 13:48:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040109134812.6fa874c8@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Chas Williams
 <chas@cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ATM for unsigned length send/recvmsg to match new prototype.

diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Dec  8 16:19:46 2003
+++ b/net/atm/common.c	Mon Dec  8 16:19:46 2003
@@ -463,7 +463,7 @@
 
 
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		int size, int flags)
+		size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
@@ -503,7 +503,7 @@
 
 
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len)
+		size_t total_len)
 {
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Dec  8 16:19:46 2003
+++ b/net/atm/common.h	Mon Dec  8 16:19:46 2003
@@ -14,9 +14,9 @@
 int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		int size, int flags);
+		size_t size, int flags);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		int total_len);
+		size_t total_len);
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_setsockopt(struct socket *sock, int level, int optname, char *optval,
