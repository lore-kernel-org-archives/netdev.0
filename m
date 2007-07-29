From: =?ISO-8859-2?Q?Rafa=B3_Bilski?= <rafalbilski@interia.pl>
Subject: IPUtils and uClibc
Date: Mon, 30 Jul 2007 00:50:39 +0200
Message-ID: <46AD19BF.7090706@interia.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp35.poczta.interia.pl ([80.48.65.35]:11593 "EHLO
	smtp4.poczta.interia.pl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751135AbXG2XQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 19:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Today I was trying to update my router based on Gentoo and uClibc. 
Unfortunatly build fails because of b* functions. Linker can't 
find them later. At first gcc is complaining that b* functions 
are impilicity declared. Acording to man pages these functions 
are deprecated anyway.
Patch is for Gentoo's iputils-20070202.

---
 clockdiff.c   |    4 ++--
 ping.c        |   13 +++++++------
 rdisc.c       |    6 +++---
 traceroute6.c |    6 +++---
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/clockdiff.c b/clockdiff.c
index e17e0b8..ee7bb76 100644
--- a/clockdiff.c
+++ b/clockdiff.c
@@ -594,7 +594,7 @@ main(int argc, char *argv[])
 
 	memset(&server, 0, sizeof(server));
 	server.sin_family = hp->h_addrtype;
-	bcopy(hp->h_addr, &(server.sin_addr.s_addr), 4); 
+	memcpy(&(server.sin_addr.s_addr), hp->h_addr, 4); 
 
 	if (connect(sock_raw, (struct sockaddr*)&server, sizeof(server)) == -1) {
 		perror("connect");
@@ -605,7 +605,7 @@ main(int argc, char *argv[])
 		socklen_t addrlen = sizeof(myaddr);
 		unsigned char rspace[ip_opt_len];
 
-	        bzero(rspace, sizeof(rspace));
+	        memset(rspace, 0, sizeof(rspace));
 		rspace[0] = IPOPT_TIMESTAMP;
 		rspace[1] = ip_opt_len;
 		rspace[2] = 5;
diff --git a/ping.c b/ping.c
index 561e71a..6148fd9 100644
--- a/ping.c
+++ b/ping.c
@@ -58,6 +58,7 @@ char copyright[] =
  *	This program has to run SUID to ROOT to access the ICMP socket.
  */
 
+#include <string.h>
 #include "ping_common.h"
 
 #include <netinet/ip.h>
@@ -235,7 +236,7 @@ main(int argc, char **argv)
 	while (argc > 0) {
 		target = *argv;
 
-		bzero((char *)&whereto, sizeof(whereto));
+		memset((char *)&whereto, 0, sizeof(whereto));
 		whereto.sin_family = AF_INET;
 		if (inet_aton(target, &whereto.sin_addr) == 1) {
 			hostname = target;
@@ -393,7 +394,7 @@ main(int argc, char **argv)
 
 	/* record route option */
 	if (options & F_RROUTE) {
-	        bzero(rspace, sizeof(rspace));
+	        memset(rspace, 0, sizeof(rspace));
 		rspace[0] = IPOPT_NOP;
 		rspace[1+IPOPT_OPTVAL] = IPOPT_RR;
 		rspace[1+IPOPT_OLEN] = sizeof(rspace)-1;
@@ -405,7 +406,7 @@ main(int argc, char **argv)
 		}
 	}
 	if (options & F_TIMESTAMP) {
-	        bzero(rspace, sizeof(rspace));
+	        memset(rspace, 0, sizeof(rspace));
 		rspace[0] = IPOPT_TIMESTAMP;
 		rspace[1] = (ts_type==IPOPT_TS_TSONLY ? 40 : 36);
 		rspace[2] = 5;
@@ -427,7 +428,7 @@ main(int argc, char **argv)
 	}
 	if (options & F_SOURCEROUTE) {
 	        int i;
-	        bzero(rspace, sizeof(rspace));
+	        memset(rspace, 0, sizeof(rspace));
 		rspace[0] = IPOPT_NOOP;
 		rspace[1+IPOPT_OPTVAL] = (options & F_SO_DONTROUTE) ? IPOPT_SSRR
 			: IPOPT_LSRR;
@@ -1009,7 +1010,7 @@ void pr_options(unsigned char * cp, int hlen)
 			if (i <= 0)
 				continue;
 			if (i == old_rrlen
-			    && !bcmp((char *)cp, old_rr, i)
+			    && !strncmp((char *)cp, old_rr, i)
 			    && !(options & F_FLOOD)) {
 				printf("\t(same route)");
 				i = ((i + 3) / 4) * 4;
@@ -1017,7 +1018,7 @@ void pr_options(unsigned char * cp, int hlen)
 				break;
 			}
 			old_rrlen = i;
-			bcopy((char *)cp, old_rr, i);
+			memcpy(old_rr, (char *)cp, i);
 			printf("\nRR: ");
 			cp++;
 			for (;;) {
diff --git a/rdisc.c b/rdisc.c
index bb223bc..b1eab40 100644
--- a/rdisc.c
+++ b/rdisc.c
@@ -409,11 +409,11 @@ next:
 		forever = 1;
 	}
 
-	bzero( (char *)&whereto, sizeof(struct sockaddr_in) );
+	memset( (char *)&whereto, 0, sizeof(struct sockaddr_in) );
 	to->sin_family = AF_INET;
 	to->sin_addr.s_addr = inet_addr(sendaddress);
 
-	bzero( (char *)&joinaddr, sizeof(struct sockaddr_in) );
+	memset( (char *)&joinaddr, 0, sizeof(struct sockaddr_in) );
 	joinaddr.sin_family = AF_INET;
 	joinaddr.sin_addr.s_addr = inet_addr(recvaddress);
 
@@ -1468,7 +1468,7 @@ rtioctl(struct in_addr addr, int op)
 	struct rtentry rt;
 	struct sockaddr_in *sin;
 
-	bzero((char *)&rt, sizeof(struct rtentry));
+	memset((char *)&rt, 0, sizeof(struct rtentry));
 	rt.rt_dst.sa_family = AF_INET;
 	rt.rt_gateway.sa_family = AF_INET;
 	rt.rt_genmask.sa_family = AF_INET;
diff --git a/traceroute6.c b/traceroute6.c
index 114cb0a..2dd5c42 100644
--- a/traceroute6.c
+++ b/traceroute6.c
@@ -276,7 +276,7 @@ char copyright[] =
 #define FD_SET(n, p)    ((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
 #define FD_CLR(n, p)    ((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
 #define FD_ISSET(n, p)  ((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
-#define FD_ZERO(p)      bzero((char *)(p), sizeof(*(p)))
+#define FD_ZERO(p)      memset((char *)(p), 0, sizeof(*(p)))
 #endif
 
 #define Fprintf (void)fprintf
@@ -422,7 +422,7 @@ int main(int argc, char *argv[])
 
 	setlinebuf (stdout);
 
-	(void) bzero((char *)&whereto, sizeof(whereto));
+	(void) memset((char *)&whereto, 0, sizeof(whereto));
 
 	to->sin6_family = AF_INET6;
 	to->sin6_port = htons(port);
@@ -534,7 +534,7 @@ int main(int argc, char *argv[])
 		saddr.sin6_port = 0;
 		close(probe_fd);
 	} else {
-		(void) bzero((char *)&saddr, sizeof(saddr));
+		(void) memset((char *)&saddr, 0, sizeof(saddr));
 		saddr.sin6_family = AF_INET6;
 		if (inet_pton(AF_INET6, source, &saddr.sin6_addr) <= 0)
 		{
-- 


----------------------------------------------------------------------
Wszystko czego potrzebujesz latem: kremy do opalania, 
stroje kapielowe, maly romans 

>>>http://link.interia.pl/f1b15

