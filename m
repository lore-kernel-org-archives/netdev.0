From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 4/4][SCTP]: make 2 functions static
Date: Wed, 20 Dec 2006 16:01:06 -0800
Message-ID: <1166659266.5722.18.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:35703 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161048AbWLUABK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 19:01:10 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBL017XR002655
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:01:07 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBL017kE284856
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:01:07 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBL017Eh015455
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 19:01:07 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: make 2 functions static

This patch makes the following needlessly global functions static:
- ipv6.c: sctp_inet6addr_event()
- protocol.c: sctp_inetaddr_event()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/sctp.h |    2 --
 net/sctp/ipv6.c         |    4 ++--
 net/sctp/protocol.c     |    4 ++--
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index c818f87..28af680 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -128,8 +128,6 @@ extern int sctp_copy_local_addr_list(str
 				     int flags);
 extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
 extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
-int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr);
 
 /*
  * sctp/socket.c
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index d8d36de..ef36be0 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -79,8 +79,8 @@ #include <net/sctp/sctp.h>
 #include <asm/uaccess.h>
 
 /* Event handler for inet6 address addition/deletion events.  */
-int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr)
+static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
+				void *ptr)
 {
 	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 3a3db56..225f39b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -601,8 +601,8 @@ static void sctp_v4_seq_dump_addr(struct
 }
 
 /* Event handler for inet address addition/deletion events.  */
-int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr)
+static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
+			       void *ptr)
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr;


