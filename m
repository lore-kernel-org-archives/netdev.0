From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/12] irda: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:37:44 -0700
Message-ID: <b61a739d31ea511b840e04f5c111207ed1710328.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0212.hostedemail.com ([216.40.44.212]:43451 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754250Ab3IWShs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:37:48 -0400
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/irda/ircomm_tty.h  | 14 +++++++-------
 include/net/irda/irda.h        | 21 ++++++++++-----------
 include/net/irda/irlap_event.h |  2 +-
 include/net/irda/irlap_frame.h |  4 ++--
 4 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/include/net/irda/ircomm_tty.h b/include/net/irda/ircomm_tty.h
index 80ffde3..0224402 100644
--- a/include/net/irda/ircomm_tty.h
+++ b/include/net/irda/ircomm_tty.h
@@ -105,13 +105,13 @@ struct ircomm_tty_cb {
 void ircomm_tty_start(struct tty_struct *tty);
 void ircomm_tty_check_modem_status(struct ircomm_tty_cb *self);
 
-extern int ircomm_tty_tiocmget(struct tty_struct *tty);
-extern int ircomm_tty_tiocmset(struct tty_struct *tty,
-			       unsigned int set, unsigned int clear);
-extern int ircomm_tty_ioctl(struct tty_struct *tty, 
-			    unsigned int cmd, unsigned long arg);
-extern void ircomm_tty_set_termios(struct tty_struct *tty, 
-				   struct ktermios *old_termios);
+int ircomm_tty_tiocmget(struct tty_struct *tty);
+int ircomm_tty_tiocmset(struct tty_struct *tty, unsigned int set,
+			unsigned int clear);
+int ircomm_tty_ioctl(struct tty_struct *tty, unsigned int cmd,
+		     unsigned long arg);
+void ircomm_tty_set_termios(struct tty_struct *tty,
+			    struct ktermios *old_termios);
 
 #endif
 
diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 3bed61d..a059465 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -112,20 +112,19 @@ do { if(!(expr)) { \
 struct net_device;
 struct packet_type;
 
-extern void irda_proc_register(void);
-extern void irda_proc_unregister(void);
+void irda_proc_register(void);
+void irda_proc_unregister(void);
 
-extern int irda_sysctl_register(void);
-extern void irda_sysctl_unregister(void);
+int irda_sysctl_register(void);
+void irda_sysctl_unregister(void);
 
-extern int irsock_init(void);
-extern void irsock_cleanup(void);
+int irsock_init(void);
+void irsock_cleanup(void);
 
-extern int irda_nl_register(void);
-extern void irda_nl_unregister(void);
+int irda_nl_register(void);
+void irda_nl_unregister(void);
 
-extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
-			    struct packet_type *ptype,
-			    struct net_device *orig_dev);
+int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
+		     struct packet_type *ptype, struct net_device *orig_dev);
 
 #endif /* NET_IRDA_H */
diff --git a/include/net/irda/irlap_event.h b/include/net/irda/irlap_event.h
index 4c90824..f9d88da 100644
--- a/include/net/irda/irlap_event.h
+++ b/include/net/irda/irlap_event.h
@@ -126,6 +126,6 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 		    struct sk_buff *skb, struct irlap_info *info);
 void irlap_print_event(IRLAP_EVENT event);
 
-extern int irlap_qos_negotiate(struct irlap_cb *self, struct sk_buff *skb);
+int irlap_qos_negotiate(struct irlap_cb *self, struct sk_buff *skb);
 
 #endif
diff --git a/include/net/irda/irlap_frame.h b/include/net/irda/irlap_frame.h
index 6b1dc4f..57173ae 100644
--- a/include/net/irda/irlap_frame.h
+++ b/include/net/irda/irlap_frame.h
@@ -163,7 +163,7 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command);
 void irlap_send_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 			 __u8 caddr, int command);
 
-extern int irlap_insert_qos_negotiation_params(struct irlap_cb *self, 
-					       struct sk_buff *skb);
+int irlap_insert_qos_negotiation_params(struct irlap_cb *self,
+					struct sk_buff *skb);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
