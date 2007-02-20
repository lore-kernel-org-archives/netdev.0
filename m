From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/irda/: proper prototypes
Date: Tue, 20 Feb 2007 01:07:21 +0100
Message-ID: <20070220000720.GR13958@stusta.de>
References: <200702060031.l160VuqL004621@shell0.pdx.osdl.net> <20070205.180142.35665788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:36075 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965579AbXBTAHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 19:07:22 -0500
Content-Disposition: inline
In-Reply-To: <20070205.180142.35665788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 06:01:42PM -0800, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Mon, 05 Feb 2007 16:30:53 -0800
> 
> > From: Adrian Bunk <bunk@stusta.de>
> > 
> > Add proper prototypes for some functions in include/net/irda/irda.h
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > Acked-by: Samuel Ortiz <samuel@sortiz.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I NAK'd this so that Adrian would go add "extern" to the
> function declarations in the header file.
> 
> Please drop this, Adrian will resend once he fixes it up.

Sorry, I should have sent this earlier.
Updated patch below.

cu
Adrian


<--  snip  -->


This patch adds proper prototypes for some functions in
include/net/irda/irda.h

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/irda/irda.h |   16 ++++++++++++++++
 net/irda/irmod.c        |   13 -------------
 2 files changed, 16 insertions(+), 13 deletions(-)

--- linux-2.6.20-rc1-mm1/include/net/irda/irda.h.old	2006-12-18 02:49:02.000000000 +0100
+++ linux-2.6.20-rc1-mm1/include/net/irda/irda.h	2006-12-18 02:58:02.000000000 +0100
@@ -113,4 +113,20 @@
 #define IAS_IRCOMM_ID 0x2343
 #define IAS_IRLPT_ID  0x9876
 
+struct net_device;
+struct packet_type;
+
+extern void irda_proc_register(void);
+extern void irda_proc_unregister(void);
+
+extern int irda_sysctl_register(void);
+extern void irda_sysctl_unregister(void);
+
+extern int irsock_init(void);
+extern void irsock_cleanup(void);
+
+extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
+			    struct packet_type *ptype,
+			    struct net_device *orig_dev);
+
 #endif /* NET_IRDA_H */
--- linux-2.6.20-rc1-mm1/net/irda/irmod.c.old	2006-12-18 02:52:18.000000000 +0100
+++ linux-2.6.20-rc1-mm1/net/irda/irmod.c	2006-12-18 02:53:59.000000000 +0100
@@ -42,19 +42,6 @@
 #include <net/irda/irttp.h>		/* irttp_init */
 #include <net/irda/irda_device.h>	/* irda_device_init */
 
-/* irproc.c */
-extern void irda_proc_register(void);
-extern void irda_proc_unregister(void);
-/* irsysctl.c */
-extern int  irda_sysctl_register(void);
-extern void irda_sysctl_unregister(void);
-/* af_irda.c */
-extern int  irsock_init(void);
-extern void irsock_cleanup(void);
-/* irlap_frame.c */
-extern int  irlap_driver_rcv(struct sk_buff *, struct net_device *,
-			     struct packet_type *, struct net_device *);
-
 /*
  * Module parameters
  */


