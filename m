From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ppp: make channel_ops const
Date: Wed, 4 Aug 2010 10:34:36 -0700
Message-ID: <20100804103436.72e234d6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37126 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab0HDRej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 13:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PPP channel ops structure should be const.
Cleanup the declarations to use standard C99 format.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/char/pcmcia/ipwireless/network.c |    2 +-
 drivers/net/ppp_async.c                  |    6 +++---
 drivers/net/ppp_synctty.c                |    6 +++---
 drivers/net/pppoe.c                      |    4 ++--
 include/linux/ppp_channel.h              |    2 +-
 net/atm/pppoatm.c                        |    2 +-
 net/irda/irnet/irnet_ppp.c               |    2 +-
 net/l2tp/l2tp_ppp.c                      |    5 ++++-
 8 files changed, 16 insertions(+), 13 deletions(-)

--- a/drivers/char/pcmcia/ipwireless/network.c	2010-08-04 10:27:11.127905769 -0700
+++ b/drivers/char/pcmcia/ipwireless/network.c	2010-08-04 10:27:25.891960410 -0700
@@ -239,7 +239,7 @@ static int ipwireless_ppp_ioctl(struct p
 	return err;
 }
 
-static struct ppp_channel_ops ipwireless_ppp_channel_ops = {
+static const struct ppp_channel_ops ipwireless_ppp_channel_ops = {
 	.start_xmit = ipwireless_ppp_start_xmit,
 	.ioctl      = ipwireless_ppp_ioctl
 };
--- a/drivers/net/ppp_async.c	2010-08-04 10:27:11.143905820 -0700
+++ b/drivers/net/ppp_async.c	2010-08-04 10:27:56.180089452 -0700
@@ -108,9 +108,9 @@ static void ppp_async_process(unsigned l
 static void async_lcp_peek(struct asyncppp *ap, unsigned char *data,
 			   int len, int inbound);
 
-static struct ppp_channel_ops async_ops = {
-	ppp_async_send,
-	ppp_async_ioctl
+static const struct ppp_channel_ops async_ops = {
+	.start_xmit = ppp_async_send,
+	.ioctl      = ppp_async_ioctl,
 };
 
 /*
--- a/drivers/net/ppp_synctty.c	2010-08-04 10:27:11.159905879 -0700
+++ b/drivers/net/ppp_synctty.c	2010-08-04 10:28:16.548188773 -0700
@@ -97,9 +97,9 @@ static void ppp_sync_flush_output(struct
 static void ppp_sync_input(struct syncppp *ap, const unsigned char *buf,
 			   char *flags, int count);
 
-static struct ppp_channel_ops sync_ops = {
-	ppp_sync_send,
-	ppp_sync_ioctl
+static const struct ppp_channel_ops sync_ops = {
+	.start_xmit = ppp_sync_send,
+	.ioctl      = ppp_sync_ioctl,
 };
 
 /*
--- a/drivers/net/pppoe.c	2010-08-04 10:27:11.175905937 -0700
+++ b/drivers/net/pppoe.c	2010-08-04 10:31:18.101487390 -0700
@@ -92,7 +92,7 @@
 static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb);
 
 static const struct proto_ops pppoe_ops;
-static struct ppp_channel_ops pppoe_chan_ops;
+static const struct ppp_channel_ops pppoe_chan_ops;
 
 /* per-net private data for this module */
 static int pppoe_net_id __read_mostly;
@@ -963,7 +963,7 @@ static int pppoe_xmit(struct ppp_channel
 	return __pppoe_xmit(sk, skb);
 }
 
-static struct ppp_channel_ops pppoe_chan_ops = {
+static const struct ppp_channel_ops pppoe_chan_ops = {
 	.start_xmit = pppoe_xmit,
 };
 
--- a/include/linux/ppp_channel.h	2010-08-04 10:27:11.191905992 -0700
+++ b/include/linux/ppp_channel.h	2010-08-04 10:30:10.388919874 -0700
@@ -36,7 +36,7 @@ struct ppp_channel_ops {
 
 struct ppp_channel {
 	void		*private;	/* channel private data */
-	struct ppp_channel_ops *ops;	/* operations for this channel */
+	const struct ppp_channel_ops *ops; /* operations for this channel */
 	int		mtu;		/* max transmit packet size */
 	int		hdrlen;		/* amount of headroom channel needs */
 	void		*ppp;		/* opaque to channel */
--- a/net/atm/pppoatm.c	2010-08-04 10:27:11.207906046 -0700
+++ b/net/atm/pppoatm.c	2010-08-04 10:28:41.956326440 -0700
@@ -260,7 +260,7 @@ static int pppoatm_devppp_ioctl(struct p
 	return -ENOTTY;
 }
 
-static /*const*/ struct ppp_channel_ops pppoatm_ops = {
+static const struct ppp_channel_ops pppoatm_ops = {
 	.start_xmit = pppoatm_send,
 	.ioctl = pppoatm_devppp_ioctl,
 };
--- a/net/irda/irnet/irnet_ppp.c	2010-08-04 10:27:11.219906092 -0700
+++ b/net/irda/irnet/irnet_ppp.c	2010-08-04 10:28:48.764365886 -0700
@@ -20,7 +20,7 @@
 /* Please put other headers in irnet.h - Thanks */
 
 /* Generic PPP callbacks (to call us) */
-static struct ppp_channel_ops irnet_ppp_ops = {
+static const struct ppp_channel_ops irnet_ppp_ops = {
 	.start_xmit = ppp_irnet_send,
 	.ioctl = ppp_irnet_ioctl
 };
--- a/net/l2tp/l2tp_ppp.c	2010-08-04 10:27:11.235906147 -0700
+++ b/net/l2tp/l2tp_ppp.c	2010-08-04 10:29:11.948508171 -0700
@@ -135,7 +135,10 @@ struct pppol2tp_session {
 
 static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb);
 
-static struct ppp_channel_ops pppol2tp_chan_ops = { pppol2tp_xmit , NULL };
+static const struct ppp_channel_ops pppol2tp_chan_ops = {
+	.start_xmit =  pppol2tp_xmit,
+};
+
 static const struct proto_ops pppol2tp_ops;
 
 /* Helpers to obtain tunnel/session contexts from sockets.
