From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] use socklen_t in iputils rather than just int
Date: Wed, 20 Dec 2006 10:00:32 -0500
Message-ID: <200612201000.32723.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_QAViFRM33gZ6O7t"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59953 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965122AbWLTPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 10:00:26 -0500
Received: from home.wh0rd.org (pool-141-154-225-206.bos.east.verizon.net [141.154.225.206])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 67EEB6475C
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 15:00:24 +0000 (UTC)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_QAViFRM33gZ6O7t
Content-Type: multipart/signed;
  boundary="nextPart1502851.sM3WCzLqNn";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1502851.sM3WCzLqNn
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

a bunch of places in iputils utilize "int" lengths when in reality they sho=
uld=20
be using socklen_t
=2Dmike

--nextPart1502851.sM3WCzLqNn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFiVAQK9sYciBdMQMRAmZRAJ4ioYmtpw8T0kapy6TfwAw74OE1igCcCY5l
BkGM6UFJCFouDNZB3JhyZhM=
=DQT3
-----END PGP SIGNATURE-----

--nextPart1502851.sM3WCzLqNn--

--Boundary-00=_QAViFRM33gZ6O7t
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iputils-socklen.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iputils-socklen.patch"

Use socklen_t in all the right places.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>

diff --git a/arping.c b/arping.c
index 73a7e6f..86f1607 100644
--- a/arping.c
+++ b/arping.c
@@ -439,7 +439,7 @@ main(int argc, char **argv)
 			}
 		} else if (!dad) {
 			int on = 1;
-			int alen = sizeof(saddr);
+			socklen_t alen = sizeof(saddr);
 
 			saddr.sin_port = htons(1025);
 			saddr.sin_addr = dst;
@@ -468,7 +468,7 @@ main(int argc, char **argv)
 	}
 
 	if (1) {
-		int alen = sizeof(me);
+		socklen_t alen = sizeof(me);
 		if (getsockname(s, (struct sockaddr*)&me, &alen) == -1) {
 			perror("getsockname");
 			exit(2);
@@ -500,9 +500,9 @@ main(int argc, char **argv)
 
 	while(1) {
 		sigset_t sset, osset;
-		char packet[4096];
+		unsigned char packet[4096];
 		struct sockaddr_ll from;
-		int alen = sizeof(from);
+		socklen_t alen = sizeof(from);
 		int cc;
 
 		if ((cc = recvfrom(s, packet, sizeof(packet), 0,
diff --git a/clockdiff.c b/clockdiff.c
index 009eed4..e17e0b8 100644
--- a/clockdiff.c
+++ b/clockdiff.c
@@ -121,7 +121,7 @@ long rtt_sigma = 0;
 int
 measure(struct sockaddr_in * addr)
 {
-	int length;
+	socklen_t length;
 	int msgcount;
 	int cc, count;
 	fd_set ready;
@@ -299,7 +299,7 @@ char *myname, *hisname;
 int
 measure_opt(struct sockaddr_in * addr)
 {
-	int length;
+	socklen_t length;
 	int msgcount;
 	int cc, count;
 	fd_set ready;
@@ -602,7 +602,7 @@ main(int argc, char *argv[])
 	}
 	if (ip_opt_len) {
 		struct sockaddr_in myaddr;
-		int addrlen = sizeof(myaddr);
+		socklen_t addrlen = sizeof(myaddr);
 		unsigned char rspace[ip_opt_len];
 
 	        bzero(rspace, sizeof(rspace));
diff --git a/ping.c b/ping.c
index 825f85b..561e71a 100644
--- a/ping.c
+++ b/ping.c
@@ -259,7 +259,7 @@ main(int argc, char **argv)
 	}
 
 	if (source.sin_addr.s_addr == 0) {
-		int alen;
+		socklen_t alen;
 		struct sockaddr_in dst = whereto;
 		int probe_fd = socket(AF_INET, SOCK_DGRAM, 0);
 
diff --git a/ping6.c b/ping6.c
index 5aef459..d85a659 100644
--- a/ping6.c
+++ b/ping6.c
@@ -344,7 +344,7 @@ int main(int argc, char *argv[])
 	hostname = target;
 
 	if (ipv6_addr_any(&source.sin6_addr)) {
-		int alen;
+		socklen_t alen;
 		int probe_fd = socket(AF_INET6, SOCK_DGRAM, 0);
 
 		if (probe_fd < 0) {
diff --git a/ping_common.c b/ping_common.c
index dd111f7..acd9b8e 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -67,7 +67,7 @@ static void fill(char *patp)
 	int ii, jj, kk;
 	int pat[16];
 	char *cp;
-	char *bp = outpack+8;
+	u_char *bp = outpack+8;
 
 	for (cp = patp; *cp; cp++) {
 		if (!isxdigit(*cp)) {
@@ -393,7 +393,7 @@ resend:
 void sock_setbufs(int icmp_sock, int alloc)
 {
 	int rcvbuf, hold;
-	int tmplen = sizeof(hold);
+	socklen_t tmplen = sizeof(hold);
 
 	if (!sndbuf)
 		sndbuf = alloc;
@@ -464,7 +464,7 @@ void setup(int icmp_sock)
 
 	if (!(options & F_PINGFILLED)) {
 		int i;
-		char *p = outpack+8;
+		u_char *p = outpack+8;
 
 		/* Do not forget about case of small datalen,
 		 * fill timestamp area too!
diff --git a/rarpd.c b/rarpd.c
index 5cb0ab8..65fd57f 100644
--- a/rarpd.c
+++ b/rarpd.c
@@ -417,7 +417,7 @@ void serve_it(int fd)
 {
 	unsigned char buf[1024];
 	struct sockaddr_ll sll;
-	int sll_len = sizeof(sll);
+	socklen_t sll_len = sizeof(sll);
 	struct arphdr *a = (struct arphdr*)buf;
 	struct rarp_map *rmap;
 	unsigned char *ptr;
diff --git a/rdisc.c b/rdisc.c
index 5f598e2..dc52b3e 100644
--- a/rdisc.c
+++ b/rdisc.c
@@ -451,7 +451,7 @@ next:
 	for (;;) {
 		u_char	packet[MAXPACKET];
 		int len = sizeof (packet);
-		int fromlen = sizeof (from);
+		socklen_t fromlen = sizeof (from);
 		int cc;
 
 		cc=recvfrom(s, (char *)packet, len, 0, 
diff --git a/tftpd.c b/tftpd.c
index 301151e..39f2164 100644
--- a/tftpd.c
+++ b/tftpd.c
@@ -88,7 +88,7 @@ union {
 	struct	sockaddr_in  sin;
 	struct	sockaddr_in6 sin6;
 } from;
-int	fromlen;
+socklen_t	fromlen;
 
 #define MAXARG	1
 char	*dirs[MAXARG+1];
@@ -148,7 +148,8 @@ int main(int ac, char **av)
 	 */
 	{
 		int pid;
-		int i, j;
+		int i;
+		socklen_t j;
 
 		for (i = 1; i < 20; i++) {
 		    pid = fork();
diff --git a/traceroute6.c b/traceroute6.c
index fdb631f..114cb0a 100644
--- a/traceroute6.c
+++ b/traceroute6.c
@@ -510,7 +510,7 @@ int main(int argc, char *argv[])
 				  (char *)&on, sizeof(on));
 
 	if (source == NULL) {
-		int alen;
+		socklen_t alen;
 		int probe_fd = socket(AF_INET6, SOCK_DGRAM, 0);
 
 		if (probe_fd < 0) {

--Boundary-00=_QAViFRM33gZ6O7t--
