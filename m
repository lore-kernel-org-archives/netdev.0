From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp_diag.c -- use static,const,void
Date: Fri, 19 Sep 2003 10:06:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919100632.48dd8e27.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup internals of tcp_diag.c.  Make functions static, use const for
parameters in match functions, use void * when generic ptr is intended.

diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	Fri Sep 19 09:57:16 2003
+++ b/net/ipv4/tcp_diag.c	Fri Sep 19 09:57:16 2003
@@ -213,7 +213,7 @@
 				  int dif);
 #endif
 
-static int tcpdiag_get_exact(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int tcpdiag_get_exact(struct sk_buff *in_skb, const struct nlmsghdr *nlh)
 {
 	int err;
 	struct sock *sk;
@@ -272,7 +272,7 @@
 	return err;
 }
 
-int bitstring_match(u32 *a1, u32 *a2, int bits)
+static int bitstring_match(const u32 *a1, const u32 *a2, int bits)
 {
 	int words = bits >> 5;
 
@@ -299,12 +299,12 @@
 }
 
 
-int tcpdiag_bc_run(char *bc, int len, struct sock *sk)
+static int tcpdiag_bc_run(const void *bc, int len, struct sock *sk)
 {
 	while (len > 0) {
 		int yes = 1;
 		struct inet_opt *inet = inet_sk(sk);
-		struct tcpdiag_bc_op *op = (struct tcpdiag_bc_op*)bc;
+		const struct tcpdiag_bc_op *op = bc;
 
 		switch (op->code) {
 		case TCPDIAG_BC_NOP:
@@ -385,10 +385,10 @@
 	return (len == 0);
 }
 
-int valid_cc(char *bc, int len, int cc)
+static int valid_cc(const void *bc, int len, int cc)
 {
 	while (len >= 0) {
-		struct tcpdiag_bc_op *op = (struct tcpdiag_bc_op*)bc;
+		const struct tcpdiag_bc_op *op = bc;
 
 		if (cc > len)
 			return 0;
@@ -402,9 +402,9 @@
 	return 0;
 }
 
-int tcpdiag_bc_audit(char *bytecode, int bytecode_len)
+static int tcpdiag_bc_audit(const void *bytecode, int bytecode_len)
 {
-	char *bc = bytecode;
+	const unsigned char *bc = bytecode;
 	int  len = bytecode_len;
 
 	while (len > 0) {
@@ -442,7 +442,7 @@
 }
 
 
-int tcpdiag_dump(struct sk_buff *skb, struct netlink_callback *cb)
+static int tcpdiag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int i, num;
 	int s_i, s_num;
