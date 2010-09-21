From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: constify some ppp/pptp structs
Date: Tue, 21 Sep 2010 18:43:54 +0200
Message-ID: <1285087434.2617.697.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Kozlov <xeb@mail.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55843 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788Ab0IUQoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 12:44:00 -0400
Received: by fxm3 with SMTP id 3so1553601fxm.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 09:43:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/pppoe.c      |    2 +-
 drivers/net/pppox.c      |    4 ++--
 drivers/net/pptp.c       |    8 ++++----
 include/linux/if_pppox.h |    2 +-
 net/l2tp/l2tp_ppp.c      |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index c07de35..d72fb05 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1124,7 +1124,7 @@ static const struct proto_ops pppoe_ops = {
 	.ioctl		= pppox_ioctl,
 };
 
-static struct pppox_proto pppoe_proto = {
+static const struct pppox_proto pppoe_proto = {
 	.create	= pppoe_create,
 	.ioctl	= pppoe_ioctl,
 	.owner	= THIS_MODULE,
diff --git a/drivers/net/pppox.c b/drivers/net/pppox.c
index d4191ef..8c0d170 100644
--- a/drivers/net/pppox.c
+++ b/drivers/net/pppox.c
@@ -36,9 +36,9 @@
 
 #include <asm/uaccess.h>
 
-static struct pppox_proto *pppox_protos[PX_MAX_PROTO + 1];
+static const struct pppox_proto *pppox_protos[PX_MAX_PROTO + 1];
 
-int register_pppox_proto(int proto_num, struct pppox_proto *pp)
+int register_pppox_proto(int proto_num, const struct pppox_proto *pp)
 {
 	if (proto_num < 0 || proto_num > PX_MAX_PROTO)
 		return -EINVAL;
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 761f0ec..ccbc913 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -53,7 +53,7 @@ static struct pppox_sock **callid_sock;
 static DEFINE_SPINLOCK(chan_lock);
 
 static struct proto pptp_sk_proto __read_mostly;
-static struct ppp_channel_ops pptp_chan_ops;
+static const struct ppp_channel_ops pptp_chan_ops;
 static const struct proto_ops pptp_ops;
 
 #define PPP_LCP_ECHOREQ 0x09
@@ -628,7 +628,7 @@ static int pptp_ppp_ioctl(struct ppp_channel *chan, unsigned int cmd,
 	return err;
 }
 
-static struct ppp_channel_ops pptp_chan_ops = {
+static const struct ppp_channel_ops pptp_chan_ops = {
 	.start_xmit = pptp_xmit,
 	.ioctl      = pptp_ppp_ioctl,
 };
@@ -659,12 +659,12 @@ static const struct proto_ops pptp_ops = {
 	.ioctl      = pppox_ioctl,
 };
 
-static struct pppox_proto pppox_pptp_proto = {
+static const struct pppox_proto pppox_pptp_proto = {
 	.create = pptp_create,
 	.owner  = THIS_MODULE,
 };
 
-static struct gre_protocol gre_pptp_protocol = {
+static const struct gre_protocol gre_pptp_protocol = {
 	.handler = pptp_rcv,
 };
 
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 29bcd55..397921b 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -204,7 +204,7 @@ struct pppox_proto {
 	struct module	*owner;
 };
 
-extern int register_pppox_proto(int proto_num, struct pppox_proto *pp);
+extern int register_pppox_proto(int proto_num, const struct pppox_proto *pp);
 extern void unregister_pppox_proto(int proto_num);
 extern void pppox_unbind_sock(struct sock *sk);/* delete ppp-channel binding */
 extern int pppox_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index ff954b3..39a21d0 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1768,7 +1768,7 @@ static const struct proto_ops pppol2tp_ops = {
 	.ioctl		= pppox_ioctl,
 };
 
-static struct pppox_proto pppol2tp_proto = {
+static const struct pppox_proto pppol2tp_proto = {
 	.create		= pppol2tp_create,
 	.ioctl		= pppol2tp_ioctl
 };


