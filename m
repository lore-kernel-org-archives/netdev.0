From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sctp/: make 2 functions static
Date: Sat, 16 Dec 2006 14:57:03 +0100
Message-ID: <20061216135703.GE3388@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:3345 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753716AbWLPN5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 08:57:04 -0500
To: sri@us.ibm.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the following needlessly global functions static:
- ipv6.c: sctp_inet6addr_event()
- protocol.c: sctp_inetaddr_event()

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/sctp/sctp.h |    2 --
 net/sctp/ipv6.c         |    4 ++--
 net/sctp/protocol.c     |    4 ++--
 3 files changed, 4 insertions(+), 6 deletions(-)

--- linux-2.6.20-rc1-mm1/net/sctp/ipv6.c.old	2006-12-16 01:05:15.000000000 +0100
+++ linux-2.6.20-rc1-mm1/net/sctp/ipv6.c	2006-12-16 01:05:40.000000000 +0100
@@ -79,8 +79,8 @@
 #include <asm/uaccess.h>
 
 /* Event handler for inet6 address addition/deletion events.  */
-int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr)
+static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
+				void *ptr)
 {
 	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr;
--- linux-2.6.20-rc1-mm1/include/net/sctp/sctp.h.old	2006-12-16 01:05:47.000000000 +0100
+++ linux-2.6.20-rc1-mm1/include/net/sctp/sctp.h	2006-12-16 01:05:53.000000000 +0100
@@ -128,8 +128,6 @@
 				     int flags);
 extern struct sctp_pf *sctp_get_pf_specific(sa_family_t family);
 extern int sctp_register_pf(struct sctp_pf *, sa_family_t);
-int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr);
 
 /*
  * sctp/socket.c
--- linux-2.6.20-rc1-mm1/net/sctp/protocol.c.old	2006-12-16 01:05:59.000000000 +0100
+++ linux-2.6.20-rc1-mm1/net/sctp/protocol.c	2006-12-16 01:06:07.000000000 +0100
@@ -601,8 +601,8 @@
 }
 
 /* Event handler for inet address addition/deletion events.  */
-int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
-                        void *ptr)
+static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
+			       void *ptr)
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct sctp_sockaddr_entry *addr;

