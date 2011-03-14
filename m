From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 14:27:59 +0000
Message-ID: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:23283 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754918Ab1CNO2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:28:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch is the fifth iteration of the Xen network backend
driver for upstream Linux.

This driver ("netback") is the host side counterpart to the frontend
driver in drivers/net/xen-netfront.c. The PV protocol is also
implemented by frontend drivers in other OSes too, such as the BSDs and
even Windows.

Changes since the fourth posting, due to review from Stephen Hemminger:
      * Treat dev->features as u32 (it effectively is already and
        becomes literally so in net-next -- there's no harm in netback
        switching earlier)
      * Use stats from struct netdevice instead of a local copy.

I also added switching to per-CPU/64 bit stats (Stephen again) and
netdev->hw_features (from Micha=C5=82 Miros=C5=82aw) to my TODO list po=
st merge.

The following changes since commit 2e820f58f7ad8eaca2f194ccdfea0de63e9c=
6d78:
  Ian Campbell (1):
        xen/irq: implement bind_interdomain_evtchn_to_irqhandler for ba=
ckend drivers

are available in the git repository at:

  git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend=
/netback

Bastian Blank (1):
      xen: netback: Fix null-pointer access in netback_uevent

Christophe Saout (1):
      xen: netback: use dev_name() instead of removed ->bus_id.

Dongxiao Xu (5):
      xen: netback: Move global/static variables into struct xen_netbk.
      xen: netback: Introduce a new struct type page_ext.
      xen: netback: Multiple tasklets support.
      xen: netback: Use Kernel thread to replace the tasklet.
      xen: netback: Set allocated memory to zero from vmalloc.

Ian Campbell (63):
      xen: netback: Initial import of linux-2.6.18-xen.hg netback drive=
r.
      xen: netback: first cut at porting to upstream and cleaning up
      xen: netback: add ethtool stat to track copied skbs.
      xen: netback: make queue length parameter writeable in sysfs
      xen: netback: parent sysfs device should be set before registerin=
g.
      xen: rename netbk module xen-netback.
      xen: netback: remove unused xen_network_done code
      xen: netback: factor disconnect from backend into new function.
      xen: netback: wait for hotplug scripts to complete before signall=
ing connected to frontend
      xen: netback: Always pull through PKT_PROT_LEN bytes into the lin=
ear part of an skb.
      xen: netback: Allow setting of large MTU before rings have connec=
ted.
      xen: netback: correctly setup skb->ip_summed on receive
      xen: netback: handle NET_SKBUFF_DATA_USES_OFFSET correctly
      xen: netback: drop frag member from struct netbk_rx_meta
      xen: netback: linearise SKBs as we copy them into guest memory on=
 guest-RX.
      xen: netback: drop more relics of flipping mode
      xen: netback: check if foreign pages are actually netback-created=
 foreign pages.
      xen: netback: do not unleash netback threads until initialisation=
 is complete
      xen: netback: save interrupt state in add_to_net_schedule_list_ta=
il
      xen: netback: increase size of rx_meta array.
      xen: netback: take net_schedule_list_lock when removing entry fro=
m net_schedule_list
      xen: netback: Drop GSO SKBs which do not have csum_blank.
      xen: netback: completely remove tx_queue_timer
      Revert "xen: netback: Drop GSO SKBs which do not have csum_blank.=
"
      xen: netback: handle incoming GSO SKBs which are not CHECKSUM_PAR=
TIAL
      xen: netback: rationalise types used in count_skb_slots
      xen: netback: refactor logic for moving to a new receive buffer.
      xen: netback: refactor code to get next rx buffer into own functi=
on.
      xen: netback: simplify use of netbk_add_frag_responses
      xen: netback: cleanup coding style
      xen: netback: drop private ?PRINTK macros in favour of pr_*
      xen: netback: move under drivers/net/xen-netback/
      xen: netback: remove queue_length module option
      xen: netback: correct error return from ethtool hooks.
      xen: netback: avoid leading _ in function parameter names.
      xen: netback: drop unused debug interrupt handler.
      xen: netif: properly namespace the Xen netif protocol header.
      xen: netif: improve Kconfig help text for front- and backend driv=
ers.
      xen: netback: drop ethtool drvinfo callback
      xen: netback: use xen_netbk prefix where appropriate
      xen: netback: refactor to make all xen_netbk knowledge internal t=
o netback.c
      xen: netback: use xenvif_ prefix where appropriate
      xen: netback: add reference from xenvif to xen_netbk
      xen: netback: refactor to separate network device from worker poo=
ls
      xen: netback: switch to kthread mode and drop tasklet mode
      xen: netback: handle frames whose head crosses a page boundary
      xen: netback: return correct values from start_xmit
      xen: netback: remove useless memset to zero.
      xen: netback: use register_netdev()
      xen: netback: simplify unwinding netback_init's work on failure.
      xen: netback: use core network carrier flag.
      xen: netback: s/xenvif_queue_full/xenvif_rx_queue_full/
      xen: netback: add xenvif_rx_schedulable
      xen: netback: further separate xen_netbk and xenvif
      xen: netback: use netdev_LEVEL instead of pr_LEVEL
      xen: netback: drop rx_notify and notify_list array in favour of a=
 normal list
      xen: netback: Make dependency on PageForeign conditional
      xen: netback: completely drop foreign page support
      xen: netback: ethtool stats fields should be unsigned long
      xen: netback: do not update last_rx on receive.
      xen: netback: Allow headroom for VLAN header in SG MTU calculatio=
n.
      xen: netback: use stats from struct net_device
      xen: netback: netdevice features should be u32

James Harper (1):
      xen: netback: avoid null-pointer access in netback_uevent

Jan Beulich (1):
      xen: netback: unmap tx ring gref when mapping of rx ring gref fai=
led

Jeremy Fitzhardinge (21):
      xen: netback: don't include xen/evtchn.h
      xen: netback: use mod_timer
      xen: netback: use NET_SKB_PAD rather than "16"
      xen: netback: completely drop flip support
      xen: netback: demacro MASK_PEND_IDX
      xen: netback: convert PEND_RING_IDX into a proper typedef name
      xen: netback: rename NR_PENDING_REQS to nr_pending_reqs()
      xen: netback: pre-initialize list and spinlocks; use empty list t=
o indicate not on list
      xen: netback: remove CONFIG_XEN_NETDEV_PIPELINED_TRANSMITTER
      xen: netback: make netif_get/put inlines
      xen: netback: move code around
      xen: netback: document PKT_PROT_LEN
      xen: netback: convert to net_device_ops
      xen: netback: reinstate missing code
      xen: netback: remove debug noise
      xen: netback: don't screw around with packet gso state
      xen: netback: use dev_get/set_drvdata() inteface
      xen: netback: include linux/sched.h for TASK_* definitions
      xen: netback: use get_sset_count rather than obsolete get_stats_c=
ount
      xen: netback: minor code formatting fixup
      xen: netback: only initialize for PV domains

Keir Fraser (1):
      xen: netback: Fixes for delayed copy of tx network packets.

Konrad Rzeszutek Wilk (1):
      Fix compile warnings: ignoring return value of 'xenbus_register_b=
ackend' ..

Paul Durrant (8):
      xen: netback: Fix basic indentation issue
      xen: netback: Add a new style of passing GSO packets to frontends=
=2E
      xen: netback: Make frontend features distinct from netback featur=
e flags.
      xen: netback: Re-define PKT_PROT_LEN to be bigger.
      xen: netback: Don't count packets we don't actually receive.
      xen: netback: Remove the 500ms timeout to restart the netif queue=
=2E
      xen: netback: Add a missing test to tx_work_todo.
      xen: netback: Re-factor net_tx_action_dealloc() slightly.

Steven Smith (2):
      xen: netback: make sure that pg->mapping is never NULL for a page=
 mapped from a foreign domain.
      xen: netback: try to pull a minimum of 72 bytes into the skb data=
 area

 drivers/net/Kconfig                 |   38 +-
 drivers/net/Makefile                |    1 +
 drivers/net/xen-netback/Makefile    |    3 +
 drivers/net/xen-netback/common.h    |  161 ++++
 drivers/net/xen-netback/interface.c |  424 +++++++++
 drivers/net/xen-netback/netback.c   | 1745 +++++++++++++++++++++++++++=
++++++++
 drivers/net/xen-netback/xenbus.c    |  490 ++++++++++
 drivers/net/xen-netfront.c          |   20 +-
 include/xen/interface/io/netif.h    |   80 +-
 9 files changed, 2908 insertions(+), 54 deletions(-)
 create mode 100644 drivers/net/xen-netback/Makefile
 create mode 100644 drivers/net/xen-netback/common.h
 create mode 100644 drivers/net/xen-netback/interface.c
 create mode 100644 drivers/net/xen-netback/netback.c
 create mode 100644 drivers/net/xen-netback/xenbus.c

Changes made in the fourth posting since the third posting, due to
review from Ben Hutchings:
      * Correct type of ethtool stats variable
      * Correct maximum MTU in SG mode
      * Don't update last_rx.


Changes since the second posting, mostly due to Francois Romieu and
Konrad Rzeszutek Wilk's review, include:
      * Rebased ontop of 2.6.38-rc2 (my branch with the generic xenbus
        backend support got rebased somewhere on its journey into
        mainline 2.6.38-rc1 and so this rebase was needed to resolve
        that). The rebase also included moving the patches on top of th=
e
        last precursor patch (addition of
        bind_interdomain_evtchn_to_irqhandler, which is in linux-next).
      * Dropped receive notify arrays in favour of simple lists.
      * Dropped private carrier flag. It's not clear that the reasons
        for adding this, which may well have been valid in 2.6.18, are
        still valid today. We can revisit in the future if and when
        required.
      * A slight refactoring to more completely encapsulate driver stuf=
f
        in interface.c and backend worker pool stuff in netback.c
      * Use netdev_XXX instead of pr_XXX where appropriate
      * Various coding style etc related tweaks suggested during review=
=2E

Changes since the first posting, many due to Ben Hutching's review,
include:

      * Improved Kconfig description for XEN_NETDEV_BACKEND and
        XEN_NETDEV_FRONTEND.
      * Avoid the core networking namespaces (skb_*, netif_*, net_*).
        This led to a major refactoring since the current namespace use
        was something of a mess. Now the code tries to consistently use
        xenvif* for the device driver related stuff (interface.c) and
        xen_netbk* for the backend worker pool related stuff
        (netback.c). This cleanup extended to the
        xen/interface/io/netif.h header which required changes to
        netfront too.
      * Dropped the tasklet mode for the backend worker leaving only th=
e
        kthread mode. I will revisit the suggestion to use NAPI on the
        driver side in the future, I think it's somewhat orthogonal to
        the use of kthread here, but it seems likely to be a worthwhile
        improvement either way.
      * Dropped netbk_copy_skb. Ben requested this function be made
        generic and moved to the networking core but it turns out it wa=
s
        trivial to remove netback's reliance on this functionality, and
        avoid a bunch of unnecessary copying in the process. The
        function's semantics were a bit odd in any case so I couldn't
        imagine many other users.
      * Handle incoming GSO SKBs which are not CHECKSUM_PARTIAL
        correctly. Changed from previous behaviour (dropping the skb) t=
o
        doing a fixup after discussion of equivalent frontend patch
        which became e0ce4af920eb028f38bfd680b1d733f4c7a0b7cf.
      * Other improvements suggested by Ben (e.g. dropping pointless
        filename references from top of file comments, not including
        version.h, correct return values from ethtool hooks, dropped
        queue_length module parameter, dropped unused debug interrupt,
        etc)

Changes made for the initial upstream post of the driver vs. the out of
tree xen.git pvops version include:

      * The driver has been put through the checkpatch.pl wringer plus
        several manual cleanup passes.
      * Moved from drivers/xen/netback to drivers/net/xen-netback.
      * Most significantly the guest transmit path (i.e. what looks lik=
e
        receive to netback) has been significantly reworked to remove
        the dependency on the out of tree PageForeign page flag (a core
        kernel patch which enables a per page destructor callback on th=
e
        final put_page). This page flag is needed in order to implement
        a grant map based transmit path (where guest pages are mapped
        directly into SKB frags). Instead this version of netback uses
        grant copy operations into regular memory belonging to the
        backend domain. Reinstating the grant map functionality is
        something which I would like to revisit in the future.

Ian.
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..1826d5d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2966,12 +2966,38 @@ config XEN_NETDEV_FRONTEND
 	select XEN_XENBUS_FRONTEND
 	default y
 	help
-	  The network device frontend driver allows the kernel to
-	  access network devices exported exported by a virtual
-	  machine containing a physical network device driver. The
-	  frontend driver is intended for unprivileged guest domains;
-	  if you are compiling a kernel for a Xen guest, you almost
-	  certainly want to enable this.
+	  This driver provides support for Xen paravirtual network
+	  devices exported by a Xen network driver domain (often
+	  domain 0).
+
+	  The corresponding Linux backend driver is enabled by the
+	  CONFIG_XEN_NETDEV_BACKEND option.
+
+	  If you are compiling a kernel for use as Xen guest, you
+	  should say Y here. To compile this driver as a module, chose
+	  M here: the module will be called xen-netfront.
+
+config XEN_NETDEV_BACKEND
+	tristate "Xen backend network device"
+	depends on XEN_BACKEND
+	help
+	  This driver allows the kernel to act as a Xen network driver
+	  domain which exports paravirtual network devices to other
+	  Xen domains. These devices can be accessed by any operating
+	  system that implements a compatible front end.
+
+	  The corresponding Linux frontend driver is enabled by the
+	  CONFIG_XEN_NETDEV_FRONTEND configuration option.
+
+	  The backend driver presents a standard network device
+	  endpoint for each paravirtual network device to the driver
+	  domain network stack. These can then be bridged or routed
+	  etc in order to provide full network connectivity.
+
+	  If you are compiling a kernel to run in a Xen network driver
+	  domain (often this is domain 0) you should say Y here. To
+	  compile this driver as a module, chose M here: the module
+	  will be called xen-netback.
=20
 config ISERIES_VETH
 	tristate "iSeries Virtual Ethernet driver support"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b90738d..145dfd7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -171,6 +171,7 @@ obj-$(CONFIG_SLIP) +=3D slip.o
 obj-$(CONFIG_SLHC) +=3D slhc.o
=20
 obj-$(CONFIG_XEN_NETDEV_FRONTEND) +=3D xen-netfront.o
+obj-$(CONFIG_XEN_NETDEV_BACKEND) +=3D xen-netback/
=20
 obj-$(CONFIG_DUMMY) +=3D dummy.o
 obj-$(CONFIG_IFB) +=3D ifb.o
diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback=
/Makefile
new file mode 100644
index 0000000..e346e81
--- /dev/null
+++ b/drivers/net/xen-netback/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_XEN_NETDEV_BACKEND) :=3D xen-netback.o
+
+xen-netback-y :=3D netback.o xenbus.o interface.o
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback=
/common.h
new file mode 100644
index 0000000..5d7bbf2
--- /dev/null
+++ b/drivers/net/xen-netback/common.h
@@ -0,0 +1,161 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version=
 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaini=
ng a copy
+ * of this source file (the "Software"), to deal in the Software witho=
ut
+ * restriction, including without limitation the rights to use, copy, =
modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the S=
oftware,
+ * and to permit persons to whom the Software is furnished to do so, s=
ubject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be incl=
uded in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXP=
RESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABI=
LITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT S=
HALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OT=
HER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARI=
SING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER=
 DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __XEN_NETBACK__COMMON_H__
+#define __XEN_NETBACK__COMMON_H__
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/wait.h>
+#include <linux/sched.h>
+
+#include <xen/interface/io/netif.h>
+#include <xen/interface/grant_table.h>
+#include <xen/grant_table.h>
+#include <xen/xenbus.h>
+
+struct xen_netbk;
+
+struct xenvif {
+	/* Unique identifier for this interface. */
+	domid_t          domid;
+	unsigned int     handle;
+
+	/* Reference to netback processing backend. */
+	struct xen_netbk *netbk;
+
+	u8               fe_dev_addr[6];
+
+	/* Physical parameters of the comms window. */
+	grant_handle_t   tx_shmem_handle;
+	grant_ref_t      tx_shmem_ref;
+	grant_handle_t   rx_shmem_handle;
+	grant_ref_t      rx_shmem_ref;
+	unsigned int     irq;
+
+	/* List of frontends to notify after a batch of frames sent. */
+	struct list_head notify_list;
+
+	/* The shared rings and indexes. */
+	struct xen_netif_tx_back_ring tx;
+	struct xen_netif_rx_back_ring rx;
+	struct vm_struct *tx_comms_area;
+	struct vm_struct *rx_comms_area;
+
+	/* Flags that must not be set in dev->features */
+	u32 features_disabled;
+
+	/* Frontend feature information. */
+	u8 can_sg:1;
+	u8 gso:1;
+	u8 gso_prefix:1;
+	u8 csum:1;
+
+	/* Internal feature information. */
+	u8 can_queue:1;	    /* can queue packets for receiver? */
+
+	/*
+	 * Allow xenvif_start_xmit() to peek ahead in the rx request
+	 * ring.  This is a prediction of what rx_req_cons will be
+	 * once all queued skbs are put on the ring.
+	 */
+	RING_IDX rx_req_cons_peek;
+
+	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
+	unsigned long   credit_bytes;
+	unsigned long   credit_usec;
+	unsigned long   remaining_credit;
+	struct timer_list credit_timeout;
+
+	/* Statistics */
+	unsigned long rx_gso_checksum_fixup;
+
+	/* Miscellaneous private stuff. */
+	struct list_head schedule_list;
+	atomic_t         refcnt;
+	struct net_device *dev;
+
+	wait_queue_head_t waiting_to_free;
+};
+
+#define XEN_NETIF_TX_RING_SIZE __RING_SIZE((struct xen_netif_tx_sring =
*)0, PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __RING_SIZE((struct xen_netif_rx_sring =
*)0, PAGE_SIZE)
+
+struct xenvif *xenvif_alloc(struct device *parent,
+			    domid_t domid,
+			    unsigned int handle);
+
+int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
+		   unsigned long rx_ring_ref, unsigned int evtchn);
+void xenvif_disconnect(struct xenvif *vif);
+
+void xenvif_get(struct xenvif *vif);
+void xenvif_put(struct xenvif *vif);
+
+int xenvif_xenbus_init(void);
+
+int xenvif_schedulable(struct xenvif *vif);
+
+int xen_netbk_rx_ring_full(struct xenvif *vif);
+
+int xen_netbk_must_stop_queue(struct xenvif *vif);
+
+/* (Un)Map communication rings. */
+void xen_netbk_unmap_frontend_rings(struct xenvif *vif);
+int xen_netbk_map_frontend_rings(struct xenvif *vif,
+				 grant_ref_t tx_ring_ref,
+				 grant_ref_t rx_ring_ref);
+
+/* (De)Register a xenvif with the netback backend. */
+void xen_netbk_add_xenvif(struct xenvif *vif);
+void xen_netbk_remove_xenvif(struct xenvif *vif);
+
+/* (De)Schedule backend processing for a xenvif */
+void xen_netbk_schedule_xenvif(struct xenvif *vif);
+void xen_netbk_deschedule_xenvif(struct xenvif *vif);
+
+/* Check for SKBs from frontend and schedule backend processing */
+void xen_netbk_check_rx_xenvif(struct xenvif *vif);
+/* Receive an SKB from the frontend */
+void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb);
+
+/* Queue an SKB for transmission to the frontend */
+void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb);
+/* Notify xenvif that ring now has space to send an skb to the fronten=
d */
+void xenvif_notify_tx_completion(struct xenvif *vif);
+
+/* Returns number of ring slots required to send an skb to the fronten=
d */
+unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_b=
uff *skb);
+
+#endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
new file mode 100644
index 0000000..160f831
--- /dev/null
+++ b/drivers/net/xen-netback/interface.c
@@ -0,0 +1,424 @@
+/*
+ * Network-device interface management.
+ *
+ * Copyright (c) 2004-2005, Keir Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version=
 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaini=
ng a copy
+ * of this source file (the "Software"), to deal in the Software witho=
ut
+ * restriction, including without limitation the rights to use, copy, =
modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the S=
oftware,
+ * and to permit persons to whom the Software is furnished to do so, s=
ubject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be incl=
uded in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXP=
RESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABI=
LITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT S=
HALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OT=
HER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARI=
SING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER=
 DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+#include <linux/if_vlan.h>
+
+#include <xen/events.h>
+#include <asm/xen/hypercall.h>
+
+#define XENVIF_QUEUE_LENGTH 32
+
+void xenvif_get(struct xenvif *vif)
+{
+	atomic_inc(&vif->refcnt);
+}
+
+void xenvif_put(struct xenvif *vif)
+{
+	if (atomic_dec_and_test(&vif->refcnt))
+		wake_up(&vif->waiting_to_free);
+}
+
+int xenvif_schedulable(struct xenvif *vif)
+{
+	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
+}
+
+static int xenvif_rx_schedulable(struct xenvif *vif)
+{
+	return xenvif_schedulable(vif) && !xen_netbk_rx_ring_full(vif);
+}
+
+static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif =3D dev_id;
+
+	if (vif->netbk =3D=3D NULL)
+		return IRQ_NONE;
+
+	xen_netbk_schedule_xenvif(vif);
+
+	if (xenvif_rx_schedulable(vif))
+		netif_wake_queue(vif->dev);
+
+	return IRQ_HANDLED;
+}
+
+static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *d=
ev)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+
+	BUG_ON(skb->dev !=3D dev);
+
+	if (vif->netbk =3D=3D NULL)
+		goto drop;
+
+	/* Drop the packet if the target domain has no receive buffers. */
+	if (!xenvif_rx_schedulable(vif))
+		goto drop;
+
+	/* Reserve ring slots for the worst-case number of fragments. */
+	vif->rx_req_cons_peek +=3D xen_netbk_count_skb_slots(vif, skb);
+	xenvif_get(vif);
+
+	if (vif->can_queue && xen_netbk_must_stop_queue(vif))
+		netif_stop_queue(dev);
+
+	xen_netbk_queue_tx_skb(vif, skb);
+
+	return NETDEV_TX_OK;
+
+ drop:
+	vif->dev->stats.tx_dropped++;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+void xenvif_receive_skb(struct xenvif *vif, struct sk_buff *skb)
+{
+	netif_rx_ni(skb);
+}
+
+void xenvif_notify_tx_completion(struct xenvif *vif)
+{
+	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
+		netif_wake_queue(vif->dev);
+}
+
+static struct net_device_stats *xenvif_get_stats(struct net_device *de=
v)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	return &vif->dev->stats;
+}
+
+static void xenvif_up(struct xenvif *vif)
+{
+	xen_netbk_add_xenvif(vif);
+	enable_irq(vif->irq);
+	xen_netbk_check_rx_xenvif(vif);
+}
+
+static void xenvif_down(struct xenvif *vif)
+{
+	disable_irq(vif->irq);
+	xen_netbk_deschedule_xenvif(vif);
+	xen_netbk_remove_xenvif(vif);
+}
+
+static int xenvif_open(struct net_device *dev)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	if (netif_carrier_ok(dev))
+		xenvif_up(vif);
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int xenvif_close(struct net_device *dev)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	if (netif_carrier_ok(dev))
+		xenvif_down(vif);
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int xenvif_change_mtu(struct net_device *dev, int mtu)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	int max =3D vif->can_sg ? 65535 - VLAN_ETH_HLEN : ETH_DATA_LEN;
+
+	if (mtu > max)
+		return -EINVAL;
+	dev->mtu =3D mtu;
+	return 0;
+}
+
+static void xenvif_set_features(struct xenvif *vif)
+{
+	struct net_device *dev =3D vif->dev;
+	u32 features =3D dev->features;
+
+	if (vif->can_sg)
+		features |=3D NETIF_F_SG;
+	if (vif->gso || vif->gso_prefix)
+		features |=3D NETIF_F_TSO;
+	if (vif->csum)
+		features |=3D NETIF_F_IP_CSUM;
+
+	features &=3D ~(vif->features_disabled);
+
+	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN)
+		dev->mtu =3D ETH_DATA_LEN;
+
+	dev->features =3D features;
+}
+
+static int xenvif_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	if (data) {
+		if (!vif->csum)
+			return -EOPNOTSUPP;
+		vif->features_disabled &=3D ~NETIF_F_IP_CSUM;
+	} else {
+		vif->features_disabled |=3D NETIF_F_IP_CSUM;
+	}
+
+	xenvif_set_features(vif);
+	return 0;
+}
+
+static int xenvif_set_sg(struct net_device *dev, u32 data)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	if (data) {
+		if (!vif->can_sg)
+			return -EOPNOTSUPP;
+		vif->features_disabled &=3D ~NETIF_F_SG;
+	} else {
+		vif->features_disabled |=3D NETIF_F_SG;
+	}
+
+	xenvif_set_features(vif);
+	return 0;
+}
+
+static int xenvif_set_tso(struct net_device *dev, u32 data)
+{
+	struct xenvif *vif =3D netdev_priv(dev);
+	if (data) {
+		if (!vif->gso && !vif->gso_prefix)
+			return -EOPNOTSUPP;
+		vif->features_disabled &=3D ~NETIF_F_TSO;
+	} else {
+		vif->features_disabled |=3D NETIF_F_TSO;
+	}
+
+	xenvif_set_features(vif);
+	return 0;
+}
+
+static const struct xenvif_stat {
+	char name[ETH_GSTRING_LEN];
+	u16 offset;
+} xenvif_stats[] =3D {
+	{
+		"rx_gso_checksum_fixup",
+		offsetof(struct xenvif, rx_gso_checksum_fixup)
+	},
+};
+
+static int xenvif_get_sset_count(struct net_device *dev, int string_se=
t)
+{
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(xenvif_stats);
+	default:
+		return -EINVAL;
+	}
+}
+
+static void xenvif_get_ethtool_stats(struct net_device *dev,
+				     struct ethtool_stats *stats, u64 * data)
+{
+	void *vif =3D netdev_priv(dev);
+	int i;
+
+	for (i =3D 0; i < ARRAY_SIZE(xenvif_stats); i++)
+		data[i] =3D *(int *)(vif + xenvif_stats[i].offset);
+}
+
+static void xenvif_get_strings(struct net_device *dev, u32 stringset, =
u8 * data)
+{
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i =3D 0; i < ARRAY_SIZE(xenvif_stats); i++)
+			memcpy(data + i * ETH_GSTRING_LEN,
+			       xenvif_stats[i].name, ETH_GSTRING_LEN);
+		break;
+	}
+}
+
+static struct ethtool_ops xenvif_ethtool_ops =3D {
+	.get_tx_csum	=3D ethtool_op_get_tx_csum,
+	.set_tx_csum	=3D xenvif_set_tx_csum,
+	.get_sg		=3D ethtool_op_get_sg,
+	.set_sg		=3D xenvif_set_sg,
+	.get_tso	=3D ethtool_op_get_tso,
+	.set_tso	=3D xenvif_set_tso,
+	.get_link	=3D ethtool_op_get_link,
+
+	.get_sset_count =3D xenvif_get_sset_count,
+	.get_ethtool_stats =3D xenvif_get_ethtool_stats,
+	.get_strings =3D xenvif_get_strings,
+};
+
+static struct net_device_ops xenvif_netdev_ops =3D {
+	.ndo_start_xmit	=3D xenvif_start_xmit,
+	.ndo_get_stats	=3D xenvif_get_stats,
+	.ndo_open	=3D xenvif_open,
+	.ndo_stop	=3D xenvif_close,
+	.ndo_change_mtu	=3D xenvif_change_mtu,
+};
+
+struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
+			    unsigned int handle)
+{
+	int err;
+	struct net_device *dev;
+	struct xenvif *vif;
+	char name[IFNAMSIZ] =3D {};
+
+	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
+	dev =3D alloc_netdev(sizeof(struct xenvif), name, ether_setup);
+	if (dev =3D=3D NULL) {
+		pr_warn("Could not allocate netdev\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	SET_NETDEV_DEV(dev, parent);
+
+	vif =3D netdev_priv(dev);
+	vif->domid  =3D domid;
+	vif->handle =3D handle;
+	vif->netbk  =3D NULL;
+	vif->can_sg =3D 1;
+	vif->csum =3D 1;
+	atomic_set(&vif->refcnt, 1);
+	init_waitqueue_head(&vif->waiting_to_free);
+	vif->dev =3D dev;
+	INIT_LIST_HEAD(&vif->schedule_list);
+	INIT_LIST_HEAD(&vif->notify_list);
+
+	vif->credit_bytes =3D vif->remaining_credit =3D ~0UL;
+	vif->credit_usec  =3D 0UL;
+	init_timer(&vif->credit_timeout);
+	/* Initialize 'expires' now: it's used to track the credit window. */
+	vif->credit_timeout.expires =3D jiffies;
+
+	dev->netdev_ops	=3D &xenvif_netdev_ops;
+	xenvif_set_features(vif);
+	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
+
+	dev->tx_queue_len =3D XENVIF_QUEUE_LENGTH;
+
+	/*
+	 * Initialise a dummy MAC address. We choose the numerically
+	 * largest non-broadcast address to prevent the address getting
+	 * stolen by an Ethernet bridge for STP purposes.
+	 * (FE:FF:FF:FF:FF:FF)
+	 */
+	memset(dev->dev_addr, 0xFF, ETH_ALEN);
+	dev->dev_addr[0] &=3D ~0x01;
+
+	netif_carrier_off(dev);
+
+	err =3D register_netdev(dev);
+	if (err) {
+		netdev_warn(dev, "Could not register device: err=3D%d\n", err);
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	netdev_dbg(dev, "Successfully created xenvif\n");
+	return vif;
+}
+
+int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
+		   unsigned long rx_ring_ref, unsigned int evtchn)
+{
+	int err =3D -ENOMEM;
+
+	/* Already connected through? */
+	if (vif->irq)
+		return 0;
+
+	xenvif_set_features(vif);
+
+	err =3D xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
+	if (err < 0)
+		goto err;
+
+	err =3D bind_interdomain_evtchn_to_irqhandler(
+		vif->domid, evtchn, xenvif_interrupt, 0,
+		vif->dev->name, vif);
+	if (err < 0)
+		goto err_unmap;
+	vif->irq =3D err;
+	disable_irq(vif->irq);
+
+	xenvif_get(vif);
+
+	rtnl_lock();
+	netif_carrier_on(vif->dev);
+	if (netif_running(vif->dev))
+		xenvif_up(vif);
+	rtnl_unlock();
+
+	return 0;
+err_unmap:
+	xen_netbk_unmap_frontend_rings(vif);
+err:
+	return err;
+}
+
+void xenvif_disconnect(struct xenvif *vif)
+{
+	struct net_device *dev =3D vif->dev;
+	if (netif_carrier_ok(dev)) {
+		rtnl_lock();
+		netif_carrier_off(dev); /* discard queued packets */
+		if (netif_running(dev))
+			xenvif_down(vif);
+		rtnl_unlock();
+		xenvif_put(vif);
+	}
+
+	atomic_dec(&vif->refcnt);
+	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) =3D=3D 0);
+
+	del_timer_sync(&vif->credit_timeout);
+
+	if (vif->irq)
+		unbind_from_irqhandler(vif->irq, vif);
+
+	unregister_netdev(vif->dev);
+
+	xen_netbk_unmap_frontend_rings(vif);
+
+	free_netdev(vif->dev);
+}
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
new file mode 100644
index 0000000..0e4851b
--- /dev/null
+++ b/drivers/net/xen-netback/netback.c
@@ -0,0 +1,1745 @@
+/*
+ * Back-end of the driver for virtual network devices. This portion of=
 the
+ * driver exports a 'unified' network-device interface that can be acc=
essed
+ * by any operating system that implements a compatible front end. A
+ * reference front-end implementation can be found in:
+ *  drivers/net/xen-netfront.c
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version=
 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaini=
ng a copy
+ * of this source file (the "Software"), to deal in the Software witho=
ut
+ * restriction, including without limitation the rights to use, copy, =
modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the S=
oftware,
+ * and to permit persons to whom the Software is furnished to do so, s=
ubject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be incl=
uded in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXP=
RESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABI=
LITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT S=
HALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OT=
HER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARI=
SING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER=
 DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+
+#include <linux/kthread.h>
+#include <linux/if_vlan.h>
+#include <linux/udp.h>
+
+#include <net/tcp.h>
+
+#include <xen/events.h>
+#include <xen/interface/memory.h>
+
+#include <asm/xen/hypercall.h>
+#include <asm/xen/page.h>
+
+struct pending_tx_info {
+	struct xen_netif_tx_request req;
+	struct xenvif *vif;
+};
+typedef unsigned int pending_ring_idx_t;
+
+struct netbk_rx_meta {
+	int id;
+	int size;
+	int gso_size;
+};
+
+#define MAX_PENDING_REQS 256
+
+#define MAX_BUFFER_OFFSET PAGE_SIZE
+
+/* extra field used in struct page */
+union page_ext {
+	struct {
+#if BITS_PER_LONG < 64
+#define IDX_WIDTH   8
+#define GROUP_WIDTH (BITS_PER_LONG - IDX_WIDTH)
+		unsigned int group:GROUP_WIDTH;
+		unsigned int idx:IDX_WIDTH;
+#else
+		unsigned int group, idx;
+#endif
+	} e;
+	void *mapping;
+};
+
+struct xen_netbk {
+	wait_queue_head_t wq;
+	struct task_struct *task;
+
+	struct sk_buff_head rx_queue;
+	struct sk_buff_head tx_queue;
+
+	struct timer_list net_timer;
+
+	struct page *mmap_pages[MAX_PENDING_REQS];
+
+	pending_ring_idx_t pending_prod;
+	pending_ring_idx_t pending_cons;
+	struct list_head net_schedule_list;
+
+	/* Protect the net_schedule_list in netif. */
+	spinlock_t net_schedule_list_lock;
+
+	atomic_t netfront_count;
+
+	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
+
+	u16 pending_ring[MAX_PENDING_REQS];
+
+	/*
+	 * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
+	 * head/fragment page uses 2 copy operations because it
+	 * straddles two buffers in the frontend.
+	 */
+	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
+	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
+};
+
+static struct xen_netbk *xen_netbk;
+static int xen_netbk_group_nr;
+
+void xen_netbk_add_xenvif(struct xenvif *vif)
+{
+	int i;
+	int min_netfront_count;
+	int min_group =3D 0;
+	struct xen_netbk *netbk;
+
+	min_netfront_count =3D atomic_read(&xen_netbk[0].netfront_count);
+	for (i =3D 0; i < xen_netbk_group_nr; i++) {
+		int netfront_count =3D atomic_read(&xen_netbk[i].netfront_count);
+		if (netfront_count < min_netfront_count) {
+			min_group =3D i;
+			min_netfront_count =3D netfront_count;
+		}
+	}
+
+	netbk =3D &xen_netbk[min_group];
+
+	vif->netbk =3D netbk;
+	atomic_inc(&netbk->netfront_count);
+}
+
+void xen_netbk_remove_xenvif(struct xenvif *vif)
+{
+	struct xen_netbk *netbk =3D vif->netbk;
+	vif->netbk =3D NULL;
+	atomic_dec(&netbk->netfront_count);
+}
+
+static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending=
_idx);
+static void make_tx_response(struct xenvif *vif,
+			     struct xen_netif_tx_request *txp,
+			     s8       st);
+static struct xen_netif_rx_response *make_rx_response(struct xenvif *v=
if,
+					     u16      id,
+					     s8       st,
+					     u16      offset,
+					     u16      size,
+					     u16      flags);
+
+static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
+				       unsigned int idx)
+{
+	return page_to_pfn(netbk->mmap_pages[idx]);
+}
+
+static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
+					 unsigned int idx)
+{
+	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
+}
+
+/* extra field used in struct page */
+static inline void set_page_ext(struct page *pg, struct xen_netbk *net=
bk,
+				unsigned int idx)
+{
+	unsigned int group =3D netbk - xen_netbk;
+	union page_ext ext =3D { .e =3D { .group =3D group + 1, .idx =3D idx =
} };
+
+	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
+	pg->mapping =3D ext.mapping;
+}
+
+static int get_page_ext(struct page *pg,
+			unsigned int *pgroup, unsigned int *pidx)
+{
+	union page_ext ext =3D { .mapping =3D pg->mapping };
+	struct xen_netbk *netbk;
+	unsigned int group, idx;
+
+	group =3D ext.e.group - 1;
+
+	if (group < 0 || group >=3D xen_netbk_group_nr)
+		return 0;
+
+	netbk =3D &xen_netbk[group];
+
+	idx =3D ext.e.idx;
+
+	if ((idx < 0) || (idx >=3D MAX_PENDING_REQS))
+		return 0;
+
+	if (netbk->mmap_pages[idx] !=3D pg)
+		return 0;
+
+	*pgroup =3D group;
+	*pidx =3D idx;
+
+	return 1;
+}
+
+/*
+ * This is the amount of packet we copy rather than map, so that the
+ * guest can't fiddle with the contents of the headers while we do
+ * packet processing on them (netfilter, routing, etc).
+ */
+#define PKT_PROT_LEN    (ETH_HLEN + \
+			 VLAN_HLEN + \
+			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
+			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
+
+static inline pending_ring_idx_t pending_index(unsigned i)
+{
+	return i & (MAX_PENDING_REQS-1);
+}
+
+static inline pending_ring_idx_t nr_pending_reqs(struct xen_netbk *net=
bk)
+{
+	return MAX_PENDING_REQS -
+		netbk->pending_prod + netbk->pending_cons;
+}
+
+static void xen_netbk_kick_thread(struct xen_netbk *netbk)
+{
+	wake_up(&netbk->wq);
+}
+
+static int max_required_rx_slots(struct xenvif *vif)
+{
+	int max =3D DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
+
+	if (vif->can_sg || vif->gso || vif->gso_prefix)
+		max +=3D MAX_SKB_FRAGS + 1; /* extra_info + frags */
+
+	return max;
+}
+
+int xen_netbk_rx_ring_full(struct xenvif *vif)
+{
+	RING_IDX peek   =3D vif->rx_req_cons_peek;
+	RING_IDX needed =3D max_required_rx_slots(vif);
+
+	return ((vif->rx.sring->req_prod - peek) < needed) ||
+	       ((vif->rx.rsp_prod_pvt + XEN_NETIF_RX_RING_SIZE - peek) < need=
ed);
+}
+
+int xen_netbk_must_stop_queue(struct xenvif *vif)
+{
+	if (!xen_netbk_rx_ring_full(vif))
+		return 0;
+
+	vif->rx.sring->req_event =3D vif->rx_req_cons_peek +
+		max_required_rx_slots(vif);
+	mb(); /* request notification /then/ check the queue */
+
+	return xen_netbk_rx_ring_full(vif);
+}
+
+/*
+ * Returns true if we should start a new receive buffer instead of
+ * adding 'size' bytes to a buffer which currently contains 'offset'
+ * bytes.
+ */
+static bool start_new_rx_buffer(int offset, unsigned long size, int he=
ad)
+{
+	/* simple case: we have completely filled the current buffer. */
+	if (offset =3D=3D MAX_BUFFER_OFFSET)
+		return true;
+
+	/*
+	 * complex case: start a fresh buffer if the current frag
+	 * would overflow the current buffer but only if:
+	 *     (i)   this frag would fit completely in the next buffer
+	 * and (ii)  there is already some data in the current buffer
+	 * and (iii) this is not the head buffer.
+	 *
+	 * Where:
+	 * - (i) stops us splitting a frag into two copies
+	 *   unless the frag is too large for a single buffer.
+	 * - (ii) stops us from leaving a buffer pointlessly empty.
+	 * - (iii) stops us leaving the first buffer
+	 *   empty. Strictly speaking this is already covered
+	 *   by (ii) but is explicitly checked because
+	 *   netfront relies on the first buffer being
+	 *   non-empty and can crash otherwise.
+	 *
+	 * This means we will effectively linearise small
+	 * frags but do not needlessly split large buffers
+	 * into multiple copies tend to give large frags their
+	 * own buffers as before.
+	 */
+	if ((offset + size > MAX_BUFFER_OFFSET) &&
+	    (size <=3D MAX_BUFFER_OFFSET) && offset && !head)
+		return true;
+
+	return false;
+}
+
+/*
+ * Figure out how many ring slots we're going to need to send @skb to
+ * the guest. This function is essentially a dry run of
+ * netbk_gop_frag_copy.
+ */
+unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_b=
uff *skb)
+{
+	unsigned int count;
+	int i, copy_off;
+
+	count =3D DIV_ROUND_UP(
+			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
+
+	copy_off =3D skb_headlen(skb) % PAGE_SIZE;
+
+	if (skb_shinfo(skb)->gso_size)
+		count++;
+
+	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		unsigned long size =3D skb_shinfo(skb)->frags[i].size;
+		unsigned long bytes;
+		while (size > 0) {
+			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
+
+			if (start_new_rx_buffer(copy_off, size, 0)) {
+				count++;
+				copy_off =3D 0;
+			}
+
+			bytes =3D size;
+			if (copy_off + bytes > MAX_BUFFER_OFFSET)
+				bytes =3D MAX_BUFFER_OFFSET - copy_off;
+
+			copy_off +=3D bytes;
+			size -=3D bytes;
+		}
+	}
+	return count;
+}
+
+struct netrx_pending_operations {
+	unsigned copy_prod, copy_cons;
+	unsigned meta_prod, meta_cons;
+	struct gnttab_copy *copy;
+	struct netbk_rx_meta *meta;
+	int copy_off;
+	grant_ref_t copy_gref;
+};
+
+static struct netbk_rx_meta *get_next_rx_buffer(struct xenvif *vif,
+						struct netrx_pending_operations *npo)
+{
+	struct netbk_rx_meta *meta;
+	struct xen_netif_rx_request *req;
+
+	req =3D RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+
+	meta =3D npo->meta + npo->meta_prod++;
+	meta->gso_size =3D 0;
+	meta->size =3D 0;
+	meta->id =3D req->id;
+
+	npo->copy_off =3D 0;
+	npo->copy_gref =3D req->gref;
+
+	return meta;
+}
+
+/*
+ * Set up the grant operations for this fragment. If it's a flipping
+ * interface, we also set up the unmap request from here.
+ */
+static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *sk=
b,
+				struct netrx_pending_operations *npo,
+				struct page *page, unsigned long size,
+				unsigned long offset, int *head)
+{
+	struct gnttab_copy *copy_gop;
+	struct netbk_rx_meta *meta;
+	/*
+	 * These variables a used iff get_page_ext returns true,
+	 * in which case they are guaranteed to be initialized.
+	 */
+	unsigned int uninitialized_var(group), uninitialized_var(idx);
+	int foreign =3D get_page_ext(page, &group, &idx);
+	unsigned long bytes;
+
+	/* Data must not cross a page boundary. */
+	BUG_ON(size + offset > PAGE_SIZE);
+
+	meta =3D npo->meta + npo->meta_prod - 1;
+
+	while (size > 0) {
+		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
+
+		if (start_new_rx_buffer(npo->copy_off, size, *head)) {
+			/*
+			 * Netfront requires there to be some data in the head
+			 * buffer.
+			 */
+			BUG_ON(*head);
+
+			meta =3D get_next_rx_buffer(vif, npo);
+		}
+
+		bytes =3D size;
+		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes =3D MAX_BUFFER_OFFSET - npo->copy_off;
+
+		copy_gop =3D npo->copy + npo->copy_prod++;
+		copy_gop->flags =3D GNTCOPY_dest_gref;
+		if (foreign) {
+			struct xen_netbk *netbk =3D &xen_netbk[group];
+			struct pending_tx_info *src_pend;
+
+			src_pend =3D &netbk->pending_tx_info[idx];
+
+			copy_gop->source.domid =3D src_pend->vif->domid;
+			copy_gop->source.u.ref =3D src_pend->req.gref;
+			copy_gop->flags |=3D GNTCOPY_source_gref;
+		} else {
+			void *vaddr =3D page_address(page);
+			copy_gop->source.domid =3D DOMID_SELF;
+			copy_gop->source.u.gmfn =3D virt_to_mfn(vaddr);
+		}
+		copy_gop->source.offset =3D offset;
+		copy_gop->dest.domid =3D vif->domid;
+
+		copy_gop->dest.offset =3D npo->copy_off;
+		copy_gop->dest.u.ref =3D npo->copy_gref;
+		copy_gop->len =3D bytes;
+
+		npo->copy_off +=3D bytes;
+		meta->size +=3D bytes;
+
+		offset +=3D bytes;
+		size -=3D bytes;
+
+		/* Leave a gap for the GSO descriptor. */
+		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+			vif->rx.req_cons++;
+
+		*head =3D 0; /* There must be something in this buffer now. */
+
+	}
+}
+
+/*
+ * Prepare an SKB to be transmitted to the frontend.
+ *
+ * This function is responsible for allocating grant operations, meta
+ * structures, etc.
+ *
+ * It returns the number of meta structures consumed. The number of
+ * ring slots used is always equal to the number of meta slots used
+ * plus the number of GSO descriptors used. Currently, we use either
+ * zero GSO descriptors (for non-GSO packets) or one descriptor (for
+ * frontend-side LRO).
+ */
+static int netbk_gop_skb(struct sk_buff *skb,
+			 struct netrx_pending_operations *npo)
+{
+	struct xenvif *vif =3D netdev_priv(skb->dev);
+	int nr_frags =3D skb_shinfo(skb)->nr_frags;
+	int i;
+	struct xen_netif_rx_request *req;
+	struct netbk_rx_meta *meta;
+	unsigned char *data;
+	int head =3D 1;
+	int old_meta_prod;
+
+	old_meta_prod =3D npo->meta_prod;
+
+	/* Set up a GSO prefix descriptor, if necessary */
+	if (skb_shinfo(skb)->gso_size && vif->gso_prefix) {
+		req =3D RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+		meta =3D npo->meta + npo->meta_prod++;
+		meta->gso_size =3D skb_shinfo(skb)->gso_size;
+		meta->size =3D 0;
+		meta->id =3D req->id;
+	}
+
+	req =3D RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
+	meta =3D npo->meta + npo->meta_prod++;
+
+	if (!vif->gso_prefix)
+		meta->gso_size =3D skb_shinfo(skb)->gso_size;
+	else
+		meta->gso_size =3D 0;
+
+	meta->size =3D 0;
+	meta->id =3D req->id;
+	npo->copy_off =3D 0;
+	npo->copy_gref =3D req->gref;
+
+	data =3D skb->data;
+	while (data < skb_tail_pointer(skb)) {
+		unsigned int offset =3D offset_in_page(data);
+		unsigned int len =3D PAGE_SIZE - offset;
+
+		if (data + len > skb_tail_pointer(skb))
+			len =3D skb_tail_pointer(skb) - data;
+
+		netbk_gop_frag_copy(vif, skb, npo,
+				    virt_to_page(data), len, offset, &head);
+		data +=3D len;
+	}
+
+	for (i =3D 0; i < nr_frags; i++) {
+		netbk_gop_frag_copy(vif, skb, npo,
+				    skb_shinfo(skb)->frags[i].page,
+				    skb_shinfo(skb)->frags[i].size,
+				    skb_shinfo(skb)->frags[i].page_offset,
+				    &head);
+	}
+
+	return npo->meta_prod - old_meta_prod;
+}
+
+/*
+ * This is a twin to netbk_gop_skb.  Assume that netbk_gop_skb was
+ * used to set up the operations on the top of
+ * netrx_pending_operations, which have since been done.  Check that
+ * they didn't give any errors and advance over them.
+ */
+static int netbk_check_gop(struct xenvif *vif, int nr_meta_slots,
+			   struct netrx_pending_operations *npo)
+{
+	struct gnttab_copy     *copy_op;
+	int status =3D XEN_NETIF_RSP_OKAY;
+	int i;
+
+	for (i =3D 0; i < nr_meta_slots; i++) {
+		copy_op =3D npo->copy + npo->copy_cons++;
+		if (copy_op->status !=3D GNTST_okay) {
+			netdev_dbg(vif->dev,
+				   "Bad status %d from copy to DOM%d.\n",
+				   copy_op->status, vif->domid);
+			status =3D XEN_NETIF_RSP_ERROR;
+		}
+	}
+
+	return status;
+}
+
+static void netbk_add_frag_responses(struct xenvif *vif, int status,
+				     struct netbk_rx_meta *meta,
+				     int nr_meta_slots)
+{
+	int i;
+	unsigned long offset;
+
+	/* No fragments used */
+	if (nr_meta_slots <=3D 1)
+		return;
+
+	nr_meta_slots--;
+
+	for (i =3D 0; i < nr_meta_slots; i++) {
+		int flags;
+		if (i =3D=3D nr_meta_slots - 1)
+			flags =3D 0;
+		else
+			flags =3D XEN_NETRXF_more_data;
+
+		offset =3D 0;
+		make_rx_response(vif, meta[i].id, status, offset,
+				 meta[i].size, flags);
+	}
+}
+
+struct skb_cb_overlay {
+	int meta_slots_used;
+};
+
+static void xen_netbk_rx_action(struct xen_netbk *netbk)
+{
+	struct xenvif *vif =3D NULL, *tmp;
+	s8 status;
+	u16 irq, flags;
+	struct xen_netif_rx_response *resp;
+	struct sk_buff_head rxq;
+	struct sk_buff *skb;
+	LIST_HEAD(notify);
+	int ret;
+	int nr_frags;
+	int count;
+	unsigned long offset;
+	struct skb_cb_overlay *sco;
+
+	struct netrx_pending_operations npo =3D {
+		.copy  =3D netbk->grant_copy_op,
+		.meta  =3D netbk->meta,
+	};
+
+	skb_queue_head_init(&rxq);
+
+	count =3D 0;
+
+	while ((skb =3D skb_dequeue(&netbk->rx_queue)) !=3D NULL) {
+		vif =3D netdev_priv(skb->dev);
+		nr_frags =3D skb_shinfo(skb)->nr_frags;
+
+		sco =3D (struct skb_cb_overlay *)skb->cb;
+		sco->meta_slots_used =3D netbk_gop_skb(skb, &npo);
+
+		count +=3D nr_frags + 1;
+
+		__skb_queue_tail(&rxq, skb);
+
+		/* Filled the batch queue? */
+		if (count + MAX_SKB_FRAGS >=3D XEN_NETIF_RX_RING_SIZE)
+			break;
+	}
+
+	BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
+
+	if (!npo.copy_prod)
+		return;
+
+	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
+	ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_o=
p,
+					npo.copy_prod);
+	BUG_ON(ret !=3D 0);
+
+	while ((skb =3D __skb_dequeue(&rxq)) !=3D NULL) {
+		sco =3D (struct skb_cb_overlay *)skb->cb;
+
+		vif =3D netdev_priv(skb->dev);
+
+		if (netbk->meta[npo.meta_cons].gso_size && vif->gso_prefix) {
+			resp =3D RING_GET_RESPONSE(&vif->rx,
+						vif->rx.rsp_prod_pvt++);
+
+			resp->flags =3D XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
+
+			resp->offset =3D netbk->meta[npo.meta_cons].gso_size;
+			resp->id =3D netbk->meta[npo.meta_cons].id;
+			resp->status =3D sco->meta_slots_used;
+
+			npo.meta_cons++;
+			sco->meta_slots_used--;
+		}
+
+
+		vif->dev->stats.tx_bytes +=3D skb->len;
+		vif->dev->stats.tx_packets++;
+
+		status =3D netbk_check_gop(vif, sco->meta_slots_used, &npo);
+
+		if (sco->meta_slots_used =3D=3D 1)
+			flags =3D 0;
+		else
+			flags =3D XEN_NETRXF_more_data;
+
+		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) /* local packet? */
+			flags |=3D XEN_NETRXF_csum_blank | XEN_NETRXF_data_validated;
+		else if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
+			/* remote but checksummed. */
+			flags |=3D XEN_NETRXF_data_validated;
+
+		offset =3D 0;
+		resp =3D make_rx_response(vif, netbk->meta[npo.meta_cons].id,
+					status, offset,
+					netbk->meta[npo.meta_cons].size,
+					flags);
+
+		if (netbk->meta[npo.meta_cons].gso_size && !vif->gso_prefix) {
+			struct xen_netif_extra_info *gso =3D
+				(struct xen_netif_extra_info *)
+				RING_GET_RESPONSE(&vif->rx,
+						  vif->rx.rsp_prod_pvt++);
+
+			resp->flags |=3D XEN_NETRXF_extra_info;
+
+			gso->u.gso.size =3D netbk->meta[npo.meta_cons].gso_size;
+			gso->u.gso.type =3D XEN_NETIF_GSO_TYPE_TCPV4;
+			gso->u.gso.pad =3D 0;
+			gso->u.gso.features =3D 0;
+
+			gso->type =3D XEN_NETIF_EXTRA_TYPE_GSO;
+			gso->flags =3D 0;
+		}
+
+		netbk_add_frag_responses(vif, status,
+					 netbk->meta + npo.meta_cons + 1,
+					 sco->meta_slots_used);
+
+		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
+		irq =3D vif->irq;
+		if (ret && list_empty(&vif->notify_list))
+			list_add_tail(&vif->notify_list, &notify);
+
+		xenvif_notify_tx_completion(vif);
+
+		xenvif_put(vif);
+		npo.meta_cons +=3D sco->meta_slots_used;
+		dev_kfree_skb(skb);
+	}
+
+	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
+		notify_remote_via_irq(vif->irq);
+		list_del_init(&vif->notify_list);
+	}
+
+	/* More work to do? */
+	if (!skb_queue_empty(&netbk->rx_queue) &&
+			!timer_pending(&netbk->net_timer))
+		xen_netbk_kick_thread(netbk);
+}
+
+void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
+{
+	struct xen_netbk *netbk =3D vif->netbk;
+
+	skb_queue_tail(&netbk->rx_queue, skb);
+
+	xen_netbk_kick_thread(netbk);
+}
+
+static void xen_netbk_alarm(unsigned long data)
+{
+	struct xen_netbk *netbk =3D (struct xen_netbk *)data;
+	xen_netbk_kick_thread(netbk);
+}
+
+static int __on_net_schedule_list(struct xenvif *vif)
+{
+	return !list_empty(&vif->schedule_list);
+}
+
+/* Must be called with net_schedule_list_lock held */
+static void remove_from_net_schedule_list(struct xenvif *vif)
+{
+	if (likely(__on_net_schedule_list(vif))) {
+		list_del_init(&vif->schedule_list);
+		xenvif_put(vif);
+	}
+}
+
+static struct xenvif *poll_net_schedule_list(struct xen_netbk *netbk)
+{
+	struct xenvif *vif =3D NULL;
+
+	spin_lock_irq(&netbk->net_schedule_list_lock);
+	if (list_empty(&netbk->net_schedule_list))
+		goto out;
+
+	vif =3D list_first_entry(&netbk->net_schedule_list,
+			       struct xenvif, schedule_list);
+	if (!vif)
+		goto out;
+
+	xenvif_get(vif);
+
+	remove_from_net_schedule_list(vif);
+out:
+	spin_unlock_irq(&netbk->net_schedule_list_lock);
+	return vif;
+}
+
+void xen_netbk_schedule_xenvif(struct xenvif *vif)
+{
+	unsigned long flags;
+	struct xen_netbk *netbk =3D vif->netbk;
+
+	if (__on_net_schedule_list(vif))
+		goto kick;
+
+	spin_lock_irqsave(&netbk->net_schedule_list_lock, flags);
+	if (!__on_net_schedule_list(vif) &&
+	    likely(xenvif_schedulable(vif))) {
+		list_add_tail(&vif->schedule_list, &netbk->net_schedule_list);
+		xenvif_get(vif);
+	}
+	spin_unlock_irqrestore(&netbk->net_schedule_list_lock, flags);
+
+kick:
+	smp_mb();
+	if ((nr_pending_reqs(netbk) < (MAX_PENDING_REQS/2)) &&
+	    !list_empty(&netbk->net_schedule_list))
+		xen_netbk_kick_thread(netbk);
+}
+
+void xen_netbk_deschedule_xenvif(struct xenvif *vif)
+{
+	struct xen_netbk *netbk =3D vif->netbk;
+	spin_lock_irq(&netbk->net_schedule_list_lock);
+	remove_from_net_schedule_list(vif);
+	spin_unlock_irq(&netbk->net_schedule_list_lock);
+}
+
+void xen_netbk_check_rx_xenvif(struct xenvif *vif)
+{
+	int more_to_do;
+
+	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
+
+	if (more_to_do)
+		xen_netbk_schedule_xenvif(vif);
+}
+
+static void tx_add_credit(struct xenvif *vif)
+{
+	unsigned long max_burst, max_credit;
+
+	/*
+	 * Allow a burst big enough to transmit a jumbo packet of up to 128kB=
=2E
+	 * Otherwise the interface can seize up due to insufficient credit.
+	 */
+	max_burst =3D RING_GET_REQUEST(&vif->tx, vif->tx.req_cons)->size;
+	max_burst =3D min(max_burst, 131072UL);
+	max_burst =3D max(max_burst, vif->credit_bytes);
+
+	/* Take care that adding a new chunk of credit doesn't wrap to zero. =
*/
+	max_credit =3D vif->remaining_credit + vif->credit_bytes;
+	if (max_credit < vif->remaining_credit)
+		max_credit =3D ULONG_MAX; /* wrapped: clamp to ULONG_MAX */
+
+	vif->remaining_credit =3D min(max_credit, max_burst);
+}
+
+static void tx_credit_callback(unsigned long data)
+{
+	struct xenvif *vif =3D (struct xenvif *)data;
+	tx_add_credit(vif);
+	xen_netbk_check_rx_xenvif(vif);
+}
+
+static void netbk_tx_err(struct xenvif *vif,
+			 struct xen_netif_tx_request *txp, RING_IDX end)
+{
+	RING_IDX cons =3D vif->tx.req_cons;
+
+	do {
+		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
+		if (cons >=3D end)
+			break;
+		txp =3D RING_GET_REQUEST(&vif->tx, cons++);
+	} while (1);
+	vif->tx.req_cons =3D cons;
+	xen_netbk_check_rx_xenvif(vif);
+	xenvif_put(vif);
+}
+
+static int netbk_count_requests(struct xenvif *vif,
+				struct xen_netif_tx_request *first,
+				struct xen_netif_tx_request *txp,
+				int work_to_do)
+{
+	RING_IDX cons =3D vif->tx.req_cons;
+	int frags =3D 0;
+
+	if (!(first->flags & XEN_NETTXF_more_data))
+		return 0;
+
+	do {
+		if (frags >=3D work_to_do) {
+			netdev_dbg(vif->dev, "Need more frags\n");
+			return -frags;
+		}
+
+		if (unlikely(frags >=3D MAX_SKB_FRAGS)) {
+			netdev_dbg(vif->dev, "Too many frags\n");
+			return -frags;
+		}
+
+		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
+		       sizeof(*txp));
+		if (txp->size > first->size) {
+			netdev_dbg(vif->dev, "Frags galore\n");
+			return -frags;
+		}
+
+		first->size -=3D txp->size;
+		frags++;
+
+		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
+			netdev_dbg(vif->dev, "txp->offset: %x, size: %u\n",
+				 txp->offset, txp->size);
+			return -frags;
+		}
+	} while ((txp++)->flags & XEN_NETTXF_more_data);
+	return frags;
+}
+
+static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
+					 struct sk_buff *skb,
+					 unsigned long pending_idx)
+{
+	struct page *page;
+	page =3D alloc_page(GFP_KERNEL|__GFP_COLD);
+	if (!page)
+		return NULL;
+	set_page_ext(page, netbk, pending_idx);
+	netbk->mmap_pages[pending_idx] =3D page;
+	return page;
+}
+
+static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *ne=
tbk,
+						  struct xenvif *vif,
+						  struct sk_buff *skb,
+						  struct xen_netif_tx_request *txp,
+						  struct gnttab_copy *gop)
+{
+	struct skb_shared_info *shinfo =3D skb_shinfo(skb);
+	skb_frag_t *frags =3D shinfo->frags;
+	unsigned long pending_idx =3D *((u16 *)skb->data);
+	int i, start;
+
+	/* Skip first skb fragment if it is on same page as header fragment. =
*/
+	start =3D ((unsigned long)shinfo->frags[0].page =3D=3D pending_idx);
+
+	for (i =3D start; i < shinfo->nr_frags; i++, txp++) {
+		struct page *page;
+		pending_ring_idx_t index;
+		struct pending_tx_info *pending_tx_info =3D
+			netbk->pending_tx_info;
+
+		index =3D pending_index(netbk->pending_cons++);
+		pending_idx =3D netbk->pending_ring[index];
+		page =3D xen_netbk_alloc_page(netbk, skb, pending_idx);
+		if (!page)
+			return NULL;
+
+		netbk->mmap_pages[pending_idx] =3D page;
+
+		gop->source.u.ref =3D txp->gref;
+		gop->source.domid =3D vif->domid;
+		gop->source.offset =3D txp->offset;
+
+		gop->dest.u.gmfn =3D virt_to_mfn(page_address(page));
+		gop->dest.domid =3D DOMID_SELF;
+		gop->dest.offset =3D txp->offset;
+
+		gop->len =3D txp->size;
+		gop->flags =3D GNTCOPY_source_gref;
+
+		gop++;
+
+		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
+		xenvif_get(vif);
+		pending_tx_info[pending_idx].vif =3D vif;
+		frags[i].page =3D (void *)pending_idx;
+	}
+
+	return gop;
+}
+
+static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
+				  struct sk_buff *skb,
+				  struct gnttab_copy **gopp)
+{
+	struct gnttab_copy *gop =3D *gopp;
+	int pending_idx =3D *((u16 *)skb->data);
+	struct pending_tx_info *pending_tx_info =3D netbk->pending_tx_info;
+	struct xenvif *vif =3D pending_tx_info[pending_idx].vif;
+	struct xen_netif_tx_request *txp;
+	struct skb_shared_info *shinfo =3D skb_shinfo(skb);
+	int nr_frags =3D shinfo->nr_frags;
+	int i, err, start;
+
+	/* Check status of header. */
+	err =3D gop->status;
+	if (unlikely(err)) {
+		pending_ring_idx_t index;
+		index =3D pending_index(netbk->pending_prod++);
+		txp =3D &pending_tx_info[pending_idx].req;
+		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
+		netbk->pending_ring[index] =3D pending_idx;
+		xenvif_put(vif);
+	}
+
+	/* Skip first skb fragment if it is on same page as header fragment. =
*/
+	start =3D ((unsigned long)shinfo->frags[0].page =3D=3D pending_idx);
+
+	for (i =3D start; i < nr_frags; i++) {
+		int j, newerr;
+		pending_ring_idx_t index;
+
+		pending_idx =3D (unsigned long)shinfo->frags[i].page;
+
+		/* Check error status: if okay then remember grant handle. */
+		newerr =3D (++gop)->status;
+		if (likely(!newerr)) {
+			/* Had a previous error? Invalidate this fragment. */
+			if (unlikely(err))
+				xen_netbk_idx_release(netbk, pending_idx);
+			continue;
+		}
+
+		/* Error on this fragment: respond to client with an error. */
+		txp =3D &netbk->pending_tx_info[pending_idx].req;
+		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
+		index =3D pending_index(netbk->pending_prod++);
+		netbk->pending_ring[index] =3D pending_idx;
+		xenvif_put(vif);
+
+		/* Not the first error? Preceding frags already invalidated. */
+		if (err)
+			continue;
+
+		/* First error: invalidate header and preceding fragments. */
+		pending_idx =3D *((u16 *)skb->data);
+		xen_netbk_idx_release(netbk, pending_idx);
+		for (j =3D start; j < i; j++) {
+			pending_idx =3D (unsigned long)shinfo->frags[i].page;
+			xen_netbk_idx_release(netbk, pending_idx);
+		}
+
+		/* Remember the error: invalidate all subsequent fragments. */
+		err =3D newerr;
+	}
+
+	*gopp =3D gop + 1;
+	return err;
+}
+
+static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_bu=
ff *skb)
+{
+	struct skb_shared_info *shinfo =3D skb_shinfo(skb);
+	int nr_frags =3D shinfo->nr_frags;
+	int i;
+
+	for (i =3D 0; i < nr_frags; i++) {
+		skb_frag_t *frag =3D shinfo->frags + i;
+		struct xen_netif_tx_request *txp;
+		unsigned long pending_idx;
+
+		pending_idx =3D (unsigned long)frag->page;
+
+		txp =3D &netbk->pending_tx_info[pending_idx].req;
+		frag->page =3D virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		frag->size =3D txp->size;
+		frag->page_offset =3D txp->offset;
+
+		skb->len +=3D txp->size;
+		skb->data_len +=3D txp->size;
+		skb->truesize +=3D txp->size;
+
+		/* Take an extra reference to offset xen_netbk_idx_release */
+		get_page(netbk->mmap_pages[pending_idx]);
+		xen_netbk_idx_release(netbk, pending_idx);
+	}
+}
+
+static int xen_netbk_get_extras(struct xenvif *vif,
+				struct xen_netif_extra_info *extras,
+				int work_to_do)
+{
+	struct xen_netif_extra_info extra;
+	RING_IDX cons =3D vif->tx.req_cons;
+
+	do {
+		if (unlikely(work_to_do-- <=3D 0)) {
+			netdev_dbg(vif->dev, "Missing extra info\n");
+			return -EBADR;
+		}
+
+		memcpy(&extra, RING_GET_REQUEST(&vif->tx, cons),
+		       sizeof(extra));
+		if (unlikely(!extra.type ||
+			     extra.type >=3D XEN_NETIF_EXTRA_TYPE_MAX)) {
+			vif->tx.req_cons =3D ++cons;
+			netdev_dbg(vif->dev,
+				   "Invalid extra type: %d\n", extra.type);
+			return -EINVAL;
+		}
+
+		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
+		vif->tx.req_cons =3D ++cons;
+	} while (extra.flags & XEN_NETIF_EXTRA_FLAG_MORE);
+
+	return work_to_do;
+}
+
+static int netbk_set_skb_gso(struct xenvif *vif,
+			     struct sk_buff *skb,
+			     struct xen_netif_extra_info *gso)
+{
+	if (!gso->u.gso.size) {
+		netdev_dbg(vif->dev, "GSO size must not be zero.\n");
+		return -EINVAL;
+	}
+
+	/* Currently only TCPv4 S.O. is supported. */
+	if (gso->u.gso.type !=3D XEN_NETIF_GSO_TYPE_TCPV4) {
+		netdev_dbg(vif->dev, "Bad GSO type %d.\n", gso->u.gso.type);
+		return -EINVAL;
+	}
+
+	skb_shinfo(skb)->gso_size =3D gso->u.gso.size;
+	skb_shinfo(skb)->gso_type =3D SKB_GSO_TCPV4;
+
+	/* Header must be checked, and gso_segs computed. */
+	skb_shinfo(skb)->gso_type |=3D SKB_GSO_DODGY;
+	skb_shinfo(skb)->gso_segs =3D 0;
+
+	return 0;
+}
+
+static int checksum_setup(struct xenvif *vif, struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	unsigned char *th;
+	int err =3D -EPROTO;
+	int recalculate_partial_csum =3D 0;
+
+	/*
+	 * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
+	 * peers can fail to set NETRXF_csum_blank when sending a GSO
+	 * frame. In this case force the SKB to CHECKSUM_PARTIAL and
+	 * recalculate the partial checksum.
+	 */
+	if (skb->ip_summed !=3D CHECKSUM_PARTIAL && skb_is_gso(skb)) {
+		vif->rx_gso_checksum_fixup++;
+		skb->ip_summed =3D CHECKSUM_PARTIAL;
+		recalculate_partial_csum =3D 1;
+	}
+
+	/* A non-CHECKSUM_PARTIAL SKB does not require setup. */
+	if (skb->ip_summed !=3D CHECKSUM_PARTIAL)
+		return 0;
+
+	if (skb->protocol !=3D htons(ETH_P_IP))
+		goto out;
+
+	iph =3D (void *)skb->data;
+	th =3D skb->data + 4 * iph->ihl;
+	if (th >=3D skb_tail_pointer(skb))
+		goto out;
+
+	skb->csum_start =3D th - skb->head;
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		skb->csum_offset =3D offsetof(struct tcphdr, check);
+
+		if (recalculate_partial_csum) {
+			struct tcphdr *tcph =3D (struct tcphdr *)th;
+			tcph->check =3D ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 skb->len - iph->ihl*4,
+							 IPPROTO_TCP, 0);
+		}
+		break;
+	case IPPROTO_UDP:
+		skb->csum_offset =3D offsetof(struct udphdr, check);
+
+		if (recalculate_partial_csum) {
+			struct udphdr *udph =3D (struct udphdr *)th;
+			udph->check =3D ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+							 skb->len - iph->ihl*4,
+							 IPPROTO_UDP, 0);
+		}
+		break;
+	default:
+		if (net_ratelimit())
+			netdev_err(vif->dev,
+				   "Attempting to checksum a non-TCP/UDP packet, dropping a protoc=
ol %d packet\n",
+				   iph->protocol);
+		goto out;
+	}
+
+	if ((th + skb->csum_offset + 2) > skb_tail_pointer(skb))
+		goto out;
+
+	err =3D 0;
+
+out:
+	return err;
+}
+
+static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
+{
+	unsigned long now =3D jiffies;
+	unsigned long next_credit =3D
+		vif->credit_timeout.expires +
+		msecs_to_jiffies(vif->credit_usec / 1000);
+
+	/* Timer could already be pending in rare cases. */
+	if (timer_pending(&vif->credit_timeout))
+		return true;
+
+	/* Passed the point where we can replenish credit? */
+	if (time_after_eq(now, next_credit)) {
+		vif->credit_timeout.expires =3D now;
+		tx_add_credit(vif);
+	}
+
+	/* Still too big to send right now? Set a callback. */
+	if (size > vif->remaining_credit) {
+		vif->credit_timeout.data     =3D
+			(unsigned long)vif;
+		vif->credit_timeout.function =3D
+			tx_credit_callback;
+		mod_timer(&vif->credit_timeout,
+			  next_credit);
+
+		return true;
+	}
+
+	return false;
+}
+
+static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
+{
+	struct gnttab_copy *gop =3D netbk->tx_copy_ops, *request_gop;
+	struct sk_buff *skb;
+	int ret;
+
+	while (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) =
&&
+		!list_empty(&netbk->net_schedule_list)) {
+		struct xenvif *vif;
+		struct xen_netif_tx_request txreq;
+		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
+		struct page *page;
+		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
+		u16 pending_idx;
+		RING_IDX idx;
+		int work_to_do;
+		unsigned int data_len;
+		pending_ring_idx_t index;
+
+		/* Get a netif from the list with work to do. */
+		vif =3D poll_net_schedule_list(netbk);
+		if (!vif)
+			continue;
+
+		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);
+		if (!work_to_do) {
+			xenvif_put(vif);
+			continue;
+		}
+
+		idx =3D vif->tx.req_cons;
+		rmb(); /* Ensure that we see the request before we copy it. */
+		memcpy(&txreq, RING_GET_REQUEST(&vif->tx, idx), sizeof(txreq));
+
+		/* Credit-based scheduling. */
+		if (txreq.size > vif->remaining_credit &&
+		    tx_credit_exceeded(vif, txreq.size)) {
+			xenvif_put(vif);
+			continue;
+		}
+
+		vif->remaining_credit -=3D txreq.size;
+
+		work_to_do--;
+		vif->tx.req_cons =3D ++idx;
+
+		memset(extras, 0, sizeof(extras));
+		if (txreq.flags & XEN_NETTXF_extra_info) {
+			work_to_do =3D xen_netbk_get_extras(vif, extras,
+							  work_to_do);
+			idx =3D vif->tx.req_cons;
+			if (unlikely(work_to_do < 0)) {
+				netbk_tx_err(vif, &txreq, idx);
+				continue;
+			}
+		}
+
+		ret =3D netbk_count_requests(vif, &txreq, txfrags, work_to_do);
+		if (unlikely(ret < 0)) {
+			netbk_tx_err(vif, &txreq, idx - ret);
+			continue;
+		}
+		idx +=3D ret;
+
+		if (unlikely(txreq.size < ETH_HLEN)) {
+			netdev_dbg(vif->dev,
+				   "Bad packet size: %d\n", txreq.size);
+			netbk_tx_err(vif, &txreq, idx);
+			continue;
+		}
+
+		/* No crossing a page as the payload mustn't fragment. */
+		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
+			netdev_dbg(vif->dev,
+				   "txreq.offset: %x, size: %u, end: %lu\n",
+				   txreq.offset, txreq.size,
+				   (txreq.offset&~PAGE_MASK) + txreq.size);
+			netbk_tx_err(vif, &txreq, idx);
+			continue;
+		}
+
+		index =3D pending_index(netbk->pending_cons);
+		pending_idx =3D netbk->pending_ring[index];
+
+		data_len =3D (txreq.size > PKT_PROT_LEN &&
+			    ret < MAX_SKB_FRAGS) ?
+			PKT_PROT_LEN : txreq.size;
+
+		skb =3D alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
+				GFP_ATOMIC | __GFP_NOWARN);
+		if (unlikely(skb =3D=3D NULL)) {
+			netdev_dbg(vif->dev,
+				   "Can't allocate a skb in start_xmit.\n");
+			netbk_tx_err(vif, &txreq, idx);
+			break;
+		}
+
+		/* Packets passed to netif_rx() must have some headroom. */
+		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+
+		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
+			struct xen_netif_extra_info *gso;
+			gso =3D &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
+
+			if (netbk_set_skb_gso(vif, skb, gso)) {
+				kfree_skb(skb);
+				netbk_tx_err(vif, &txreq, idx);
+				continue;
+			}
+		}
+
+		/* XXX could copy straight to head */
+		page =3D xen_netbk_alloc_page(netbk, skb, pending_idx);
+		if (!page) {
+			kfree_skb(skb);
+			netbk_tx_err(vif, &txreq, idx);
+			continue;
+		}
+
+		netbk->mmap_pages[pending_idx] =3D page;
+
+		gop->source.u.ref =3D txreq.gref;
+		gop->source.domid =3D vif->domid;
+		gop->source.offset =3D txreq.offset;
+
+		gop->dest.u.gmfn =3D virt_to_mfn(page_address(page));
+		gop->dest.domid =3D DOMID_SELF;
+		gop->dest.offset =3D txreq.offset;
+
+		gop->len =3D txreq.size;
+		gop->flags =3D GNTCOPY_source_gref;
+
+		gop++;
+
+		memcpy(&netbk->pending_tx_info[pending_idx].req,
+		       &txreq, sizeof(txreq));
+		netbk->pending_tx_info[pending_idx].vif =3D vif;
+		*((u16 *)skb->data) =3D pending_idx;
+
+		__skb_put(skb, data_len);
+
+		skb_shinfo(skb)->nr_frags =3D ret;
+		if (data_len < txreq.size) {
+			skb_shinfo(skb)->nr_frags++;
+			skb_shinfo(skb)->frags[0].page =3D
+				(void *)(unsigned long)pending_idx;
+		} else {
+			/* Discriminate from any valid pending_idx value. */
+			skb_shinfo(skb)->frags[0].page =3D (void *)~0UL;
+		}
+
+		__skb_queue_tail(&netbk->tx_queue, skb);
+
+		netbk->pending_cons++;
+
+		request_gop =3D xen_netbk_get_requests(netbk, vif,
+						     skb, txfrags, gop);
+		if (request_gop =3D=3D NULL) {
+			kfree_skb(skb);
+			netbk_tx_err(vif, &txreq, idx);
+			continue;
+		}
+		gop =3D request_gop;
+
+		vif->tx.req_cons =3D idx;
+		xen_netbk_check_rx_xenvif(vif);
+
+		if ((gop-netbk->tx_copy_ops) >=3D ARRAY_SIZE(netbk->tx_copy_ops))
+			break;
+	}
+
+	return gop - netbk->tx_copy_ops;
+}
+
+static void xen_netbk_tx_submit(struct xen_netbk *netbk)
+{
+	struct gnttab_copy *gop =3D netbk->tx_copy_ops;
+	struct sk_buff *skb;
+
+	while ((skb =3D __skb_dequeue(&netbk->tx_queue)) !=3D NULL) {
+		struct xen_netif_tx_request *txp;
+		struct xenvif *vif;
+		u16 pending_idx;
+		unsigned data_len;
+
+		pending_idx =3D *((u16 *)skb->data);
+		vif =3D netbk->pending_tx_info[pending_idx].vif;
+		txp =3D &netbk->pending_tx_info[pending_idx].req;
+
+		/* Check the remap error code. */
+		if (unlikely(xen_netbk_tx_check_gop(netbk, skb, &gop))) {
+			netdev_dbg(vif->dev, "netback grant failed.\n");
+			skb_shinfo(skb)->nr_frags =3D 0;
+			kfree_skb(skb);
+			continue;
+		}
+
+		data_len =3D skb->len;
+		memcpy(skb->data,
+		       (void *)(idx_to_kaddr(netbk, pending_idx)|txp->offset),
+		       data_len);
+		if (data_len < txp->size) {
+			/* Append the packet payload as a fragment. */
+			txp->offset +=3D data_len;
+			txp->size -=3D data_len;
+		} else {
+			/* Schedule a response immediately. */
+			xen_netbk_idx_release(netbk, pending_idx);
+		}
+
+		if (txp->flags & XEN_NETTXF_csum_blank)
+			skb->ip_summed =3D CHECKSUM_PARTIAL;
+		else if (txp->flags & XEN_NETTXF_data_validated)
+			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+
+		xen_netbk_fill_frags(netbk, skb);
+
+		/*
+		 * If the initial fragment was < PKT_PROT_LEN then
+		 * pull through some bytes from the other fragments to
+		 * increase the linear region to PKT_PROT_LEN bytes.
+		 */
+		if (skb_headlen(skb) < PKT_PROT_LEN && skb_is_nonlinear(skb)) {
+			int target =3D min_t(int, skb->len, PKT_PROT_LEN);
+			__pskb_pull_tail(skb, target - skb_headlen(skb));
+		}
+
+		skb->dev      =3D vif->dev;
+		skb->protocol =3D eth_type_trans(skb, skb->dev);
+
+		if (checksum_setup(vif, skb)) {
+			netdev_dbg(vif->dev,
+				   "Can't setup checksum in net_tx_action\n");
+			kfree_skb(skb);
+			continue;
+		}
+
+		vif->dev->stats.rx_bytes +=3D skb->len;
+		vif->dev->stats.rx_packets++;
+
+		xenvif_receive_skb(vif, skb);
+	}
+}
+
+/* Called after netfront has transmitted */
+static void xen_netbk_tx_action(struct xen_netbk *netbk)
+{
+	unsigned nr_gops;
+	int ret;
+
+	nr_gops =3D xen_netbk_tx_build_gops(netbk);
+
+	if (nr_gops =3D=3D 0)
+		return;
+	ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy,
+					netbk->tx_copy_ops, nr_gops);
+	BUG_ON(ret);
+
+	xen_netbk_tx_submit(netbk);
+
+}
+
+static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending=
_idx)
+{
+	struct xenvif *vif;
+	struct pending_tx_info *pending_tx_info;
+	pending_ring_idx_t index;
+
+	/* Already complete? */
+	if (netbk->mmap_pages[pending_idx] =3D=3D NULL)
+		return;
+
+	pending_tx_info =3D &netbk->pending_tx_info[pending_idx];
+
+	vif =3D pending_tx_info->vif;
+
+	make_tx_response(vif, &pending_tx_info->req, XEN_NETIF_RSP_OKAY);
+
+	index =3D pending_index(netbk->pending_prod++);
+	netbk->pending_ring[index] =3D pending_idx;
+
+	xenvif_put(vif);
+
+	netbk->mmap_pages[pending_idx]->mapping =3D 0;
+	put_page(netbk->mmap_pages[pending_idx]);
+	netbk->mmap_pages[pending_idx] =3D NULL;
+}
+
+static void make_tx_response(struct xenvif *vif,
+			     struct xen_netif_tx_request *txp,
+			     s8       st)
+{
+	RING_IDX i =3D vif->tx.rsp_prod_pvt;
+	struct xen_netif_tx_response *resp;
+	int notify;
+
+	resp =3D RING_GET_RESPONSE(&vif->tx, i);
+	resp->id     =3D txp->id;
+	resp->status =3D st;
+
+	if (txp->flags & XEN_NETTXF_extra_info)
+		RING_GET_RESPONSE(&vif->tx, ++i)->status =3D XEN_NETIF_RSP_NULL;
+
+	vif->tx.rsp_prod_pvt =3D ++i;
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
+	if (notify)
+		notify_remote_via_irq(vif->irq);
+}
+
+static struct xen_netif_rx_response *make_rx_response(struct xenvif *v=
if,
+					     u16      id,
+					     s8       st,
+					     u16      offset,
+					     u16      size,
+					     u16      flags)
+{
+	RING_IDX i =3D vif->rx.rsp_prod_pvt;
+	struct xen_netif_rx_response *resp;
+
+	resp =3D RING_GET_RESPONSE(&vif->rx, i);
+	resp->offset     =3D offset;
+	resp->flags      =3D flags;
+	resp->id         =3D id;
+	resp->status     =3D (s16)size;
+	if (st < 0)
+		resp->status =3D (s16)st;
+
+	vif->rx.rsp_prod_pvt =3D ++i;
+
+	return resp;
+}
+
+static inline int rx_work_todo(struct xen_netbk *netbk)
+{
+	return !skb_queue_empty(&netbk->rx_queue);
+}
+
+static inline int tx_work_todo(struct xen_netbk *netbk)
+{
+
+	if (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
+			!list_empty(&netbk->net_schedule_list))
+		return 1;
+
+	return 0;
+}
+
+static int xen_netbk_kthread(void *data)
+{
+	struct xen_netbk *netbk =3D data;
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(netbk->wq,
+				rx_work_todo(netbk) ||
+				tx_work_todo(netbk) ||
+				kthread_should_stop());
+		cond_resched();
+
+		if (kthread_should_stop())
+			break;
+
+		if (rx_work_todo(netbk))
+			xen_netbk_rx_action(netbk);
+
+		if (tx_work_todo(netbk))
+			xen_netbk_tx_action(netbk);
+	}
+
+	return 0;
+}
+
+void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
+{
+	struct gnttab_unmap_grant_ref op;
+
+	if (vif->tx.sring) {
+		gnttab_set_unmap_op(&op, (unsigned long)vif->tx_comms_area->addr,
+				    GNTMAP_host_map, vif->tx_shmem_handle);
+
+		if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+			BUG();
+	}
+
+	if (vif->rx.sring) {
+		gnttab_set_unmap_op(&op, (unsigned long)vif->rx_comms_area->addr,
+				    GNTMAP_host_map, vif->rx_shmem_handle);
+
+		if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+			BUG();
+	}
+	if (vif->rx_comms_area)
+		free_vm_area(vif->rx_comms_area);
+	if (vif->tx_comms_area)
+		free_vm_area(vif->tx_comms_area);
+}
+
+int xen_netbk_map_frontend_rings(struct xenvif *vif,
+				 grant_ref_t tx_ring_ref,
+				 grant_ref_t rx_ring_ref)
+{
+	struct gnttab_map_grant_ref op;
+	struct xen_netif_tx_sring *txs;
+	struct xen_netif_rx_sring *rxs;
+
+	int err =3D -ENOMEM;
+
+	vif->tx_comms_area =3D alloc_vm_area(PAGE_SIZE);
+	if (vif->tx_comms_area =3D=3D NULL)
+		goto err;
+
+	vif->rx_comms_area =3D alloc_vm_area(PAGE_SIZE);
+	if (vif->rx_comms_area =3D=3D NULL)
+		goto err;
+
+	gnttab_set_map_op(&op, (unsigned long)vif->tx_comms_area->addr,
+			  GNTMAP_host_map, tx_ring_ref, vif->domid);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+		BUG();
+
+	if (op.status) {
+		netdev_warn(vif->dev,
+			    "failed to map tx ring. err=3D%d status=3D%d\n",
+			    err, op.status);
+		err =3D op.status;
+		goto err;
+	}
+
+	vif->tx_shmem_ref    =3D tx_ring_ref;
+	vif->tx_shmem_handle =3D op.handle;
+
+	txs =3D (struct xen_netif_tx_sring *)vif->tx_comms_area->addr;
+	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
+
+	gnttab_set_map_op(&op, (unsigned long)vif->rx_comms_area->addr,
+			  GNTMAP_host_map, rx_ring_ref, vif->domid);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+		BUG();
+
+	if (op.status) {
+		netdev_warn(vif->dev,
+			    "failed to map rx ring. err=3D%d status=3D%d\n",
+			    err, op.status);
+		err =3D op.status;
+		goto err;
+	}
+
+	vif->rx_shmem_ref     =3D rx_ring_ref;
+	vif->rx_shmem_handle  =3D op.handle;
+	vif->rx_req_cons_peek =3D 0;
+
+	rxs =3D (struct xen_netif_rx_sring *)vif->rx_comms_area->addr;
+	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
+
+	return 0;
+
+err:
+	xen_netbk_unmap_frontend_rings(vif);
+	return err;
+}
+
+static int __init netback_init(void)
+{
+	int i;
+	int rc =3D 0;
+	int group;
+
+	if (!xen_pv_domain())
+		return -ENODEV;
+
+	xen_netbk_group_nr =3D num_online_cpus();
+	xen_netbk =3D vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
+	if (!xen_netbk) {
+		printk(KERN_ALERT "%s: out of memory\n", __func__);
+		return -ENOMEM;
+	}
+
+	for (group =3D 0; group < xen_netbk_group_nr; group++) {
+		struct xen_netbk *netbk =3D &xen_netbk[group];
+		skb_queue_head_init(&netbk->rx_queue);
+		skb_queue_head_init(&netbk->tx_queue);
+
+		init_timer(&netbk->net_timer);
+		netbk->net_timer.data =3D (unsigned long)netbk;
+		netbk->net_timer.function =3D xen_netbk_alarm;
+
+		netbk->pending_cons =3D 0;
+		netbk->pending_prod =3D MAX_PENDING_REQS;
+		for (i =3D 0; i < MAX_PENDING_REQS; i++)
+			netbk->pending_ring[i] =3D i;
+
+		init_waitqueue_head(&netbk->wq);
+		netbk->task =3D kthread_create(xen_netbk_kthread,
+					     (void *)netbk,
+					     "netback/%u", group);
+
+		if (IS_ERR(netbk->task)) {
+			printk(KERN_ALERT "kthread_run() fails at netback\n");
+			del_timer(&netbk->net_timer);
+			rc =3D PTR_ERR(netbk->task);
+			goto failed_init;
+		}
+
+		kthread_bind(netbk->task, group);
+
+		INIT_LIST_HEAD(&netbk->net_schedule_list);
+
+		spin_lock_init(&netbk->net_schedule_list_lock);
+
+		atomic_set(&netbk->netfront_count, 0);
+
+		wake_up_process(netbk->task);
+	}
+
+	rc =3D xenvif_xenbus_init();
+	if (rc)
+		goto failed_init;
+
+	return 0;
+
+failed_init:
+	while (--group >=3D 0) {
+		struct xen_netbk *netbk =3D &xen_netbk[group];
+		for (i =3D 0; i < MAX_PENDING_REQS; i++) {
+			if (netbk->mmap_pages[i])
+				__free_page(netbk->mmap_pages[i]);
+		}
+		del_timer(&netbk->net_timer);
+		kthread_stop(netbk->task);
+	}
+	vfree(xen_netbk);
+	return rc;
+
+}
+
+module_init(netback_init);
+
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback=
/xenbus.c
new file mode 100644
index 0000000..22b8c35
--- /dev/null
+++ b/drivers/net/xen-netback/xenbus.c
@@ -0,0 +1,490 @@
+/*
+ * Xenbus code for netif backend
+ *
+ * Copyright (C) 2005 Rusty Russell <rusty@rustcorp.com.au>
+ * Copyright (C) 2005 XenSource Ltd
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7  USA
+*/
+
+#include "common.h"
+
+struct backend_info {
+	struct xenbus_device *dev;
+	struct xenvif *vif;
+	enum xenbus_state frontend_state;
+	struct xenbus_watch hotplug_status_watch;
+	int have_hotplug_status_watch:1;
+};
+
+static int connect_rings(struct backend_info *);
+static void connect(struct backend_info *);
+static void backend_create_xenvif(struct backend_info *be);
+static void unregister_hotplug_status_watch(struct backend_info *be);
+
+static int netback_remove(struct xenbus_device *dev)
+{
+	struct backend_info *be =3D dev_get_drvdata(&dev->dev);
+
+	unregister_hotplug_status_watch(be);
+	if (be->vif) {
+		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
+		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
+		xenvif_disconnect(be->vif);
+		be->vif =3D NULL;
+	}
+	kfree(be);
+	dev_set_drvdata(&dev->dev, NULL);
+	return 0;
+}
+
+
+/**
+ * Entry point to this code when a new device is created.  Allocate th=
e basic
+ * structures and switch to InitWait.
+ */
+static int netback_probe(struct xenbus_device *dev,
+			 const struct xenbus_device_id *id)
+{
+	const char *message;
+	struct xenbus_transaction xbt;
+	int err;
+	int sg;
+	struct backend_info *be =3D kzalloc(sizeof(struct backend_info),
+					  GFP_KERNEL);
+	if (!be) {
+		xenbus_dev_fatal(dev, -ENOMEM,
+				 "allocating backend structure");
+		return -ENOMEM;
+	}
+
+	be->dev =3D dev;
+	dev_set_drvdata(&dev->dev, be);
+
+	sg =3D 1;
+
+	do {
+		err =3D xenbus_transaction_start(&xbt);
+		if (err) {
+			xenbus_dev_fatal(dev, err, "starting transaction");
+			goto fail;
+		}
+
+		err =3D xenbus_printf(xbt, dev->nodename, "feature-sg", "%d", sg);
+		if (err) {
+			message =3D "writing feature-sg";
+			goto abort_transaction;
+		}
+
+		err =3D xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv4",
+				    "%d", sg);
+		if (err) {
+			message =3D "writing feature-gso-tcpv4";
+			goto abort_transaction;
+		}
+
+		/* We support rx-copy path. */
+		err =3D xenbus_printf(xbt, dev->nodename,
+				    "feature-rx-copy", "%d", 1);
+		if (err) {
+			message =3D "writing feature-rx-copy";
+			goto abort_transaction;
+		}
+
+		/*
+		 * We don't support rx-flip path (except old guests who don't
+		 * grok this feature flag).
+		 */
+		err =3D xenbus_printf(xbt, dev->nodename,
+				    "feature-rx-flip", "%d", 0);
+		if (err) {
+			message =3D "writing feature-rx-flip";
+			goto abort_transaction;
+		}
+
+		err =3D xenbus_transaction_end(xbt, 0);
+	} while (err =3D=3D -EAGAIN);
+
+	if (err) {
+		xenbus_dev_fatal(dev, err, "completing transaction");
+		goto fail;
+	}
+
+	err =3D xenbus_switch_state(dev, XenbusStateInitWait);
+	if (err)
+		goto fail;
+
+	/* This kicks hotplug scripts, so do it immediately. */
+	backend_create_xenvif(be);
+
+	return 0;
+
+abort_transaction:
+	xenbus_transaction_end(xbt, 1);
+	xenbus_dev_fatal(dev, err, "%s", message);
+fail:
+	pr_debug("failed");
+	netback_remove(dev);
+	return err;
+}
+
+
+/*
+ * Handle the creation of the hotplug script environment.  We add the =
script
+ * and vif variables to the environment, for the benefit of the vif-* =
hotplug
+ * scripts.
+ */
+static int netback_uevent(struct xenbus_device *xdev,
+			  struct kobj_uevent_env *env)
+{
+	struct backend_info *be =3D dev_get_drvdata(&xdev->dev);
+	char *val;
+
+	val =3D xenbus_read(XBT_NIL, xdev->nodename, "script", NULL);
+	if (IS_ERR(val)) {
+		int err =3D PTR_ERR(val);
+		xenbus_dev_fatal(xdev, err, "reading script");
+		return err;
+	} else {
+		if (add_uevent_var(env, "script=3D%s", val)) {
+			kfree(val);
+			return -ENOMEM;
+		}
+		kfree(val);
+	}
+
+	if (!be || !be->vif)
+		return 0;
+
+	return add_uevent_var(env, "vif=3D%s", be->vif->dev->name);
+}
+
+
+static void backend_create_xenvif(struct backend_info *be)
+{
+	int err;
+	long handle;
+	struct xenbus_device *dev =3D be->dev;
+
+	if (be->vif !=3D NULL)
+		return;
+
+	err =3D xenbus_scanf(XBT_NIL, dev->nodename, "handle", "%li", &handle=
);
+	if (err !=3D 1) {
+		xenbus_dev_fatal(dev, err, "reading handle");
+		return;
+	}
+
+	be->vif =3D xenvif_alloc(&dev->dev, dev->otherend_id, handle);
+	if (IS_ERR(be->vif)) {
+		err =3D PTR_ERR(be->vif);
+		be->vif =3D NULL;
+		xenbus_dev_fatal(dev, err, "creating interface");
+		return;
+	}
+
+	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
+}
+
+
+static void disconnect_backend(struct xenbus_device *dev)
+{
+	struct backend_info *be =3D dev_get_drvdata(&dev->dev);
+
+	if (be->vif) {
+		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
+		xenvif_disconnect(be->vif);
+		be->vif =3D NULL;
+	}
+}
+
+/**
+ * Callback received when the frontend's state changes.
+ */
+static void frontend_changed(struct xenbus_device *dev,
+			     enum xenbus_state frontend_state)
+{
+	struct backend_info *be =3D dev_get_drvdata(&dev->dev);
+
+	pr_debug("frontend state %s", xenbus_strstate(frontend_state));
+
+	be->frontend_state =3D frontend_state;
+
+	switch (frontend_state) {
+	case XenbusStateInitialising:
+		if (dev->state =3D=3D XenbusStateClosed) {
+			printk(KERN_INFO "%s: %s: prepare for reconnect\n",
+			       __func__, dev->nodename);
+			xenbus_switch_state(dev, XenbusStateInitWait);
+		}
+		break;
+
+	case XenbusStateInitialised:
+		break;
+
+	case XenbusStateConnected:
+		if (dev->state =3D=3D XenbusStateConnected)
+			break;
+		backend_create_xenvif(be);
+		if (be->vif)
+			connect(be);
+		break;
+
+	case XenbusStateClosing:
+		if (be->vif)
+			kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
+		disconnect_backend(dev);
+		xenbus_switch_state(dev, XenbusStateClosing);
+		break;
+
+	case XenbusStateClosed:
+		xenbus_switch_state(dev, XenbusStateClosed);
+		if (xenbus_dev_is_online(dev))
+			break;
+		/* fall through if not online */
+	case XenbusStateUnknown:
+		device_unregister(&dev->dev);
+		break;
+
+	default:
+		xenbus_dev_fatal(dev, -EINVAL, "saw state %d at frontend",
+				 frontend_state);
+		break;
+	}
+}
+
+
+static void xen_net_read_rate(struct xenbus_device *dev,
+			      unsigned long *bytes, unsigned long *usec)
+{
+	char *s, *e;
+	unsigned long b, u;
+	char *ratestr;
+
+	/* Default to unlimited bandwidth. */
+	*bytes =3D ~0UL;
+	*usec =3D 0;
+
+	ratestr =3D xenbus_read(XBT_NIL, dev->nodename, "rate", NULL);
+	if (IS_ERR(ratestr))
+		return;
+
+	s =3D ratestr;
+	b =3D simple_strtoul(s, &e, 10);
+	if ((s =3D=3D e) || (*e !=3D ','))
+		goto fail;
+
+	s =3D e + 1;
+	u =3D simple_strtoul(s, &e, 10);
+	if ((s =3D=3D e) || (*e !=3D '\0'))
+		goto fail;
+
+	*bytes =3D b;
+	*usec =3D u;
+
+	kfree(ratestr);
+	return;
+
+ fail:
+	pr_warn("Failed to parse network rate limit. Traffic unlimited.\n");
+	kfree(ratestr);
+}
+
+static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
+{
+	char *s, *e, *macstr;
+	int i;
+
+	macstr =3D s =3D xenbus_read(XBT_NIL, dev->nodename, "mac", NULL);
+	if (IS_ERR(macstr))
+		return PTR_ERR(macstr);
+
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		mac[i] =3D simple_strtoul(s, &e, 16);
+		if ((s =3D=3D e) || (*e !=3D ((i =3D=3D ETH_ALEN-1) ? '\0' : ':'))) =
{
+			kfree(macstr);
+			return -ENOENT;
+		}
+		s =3D e+1;
+	}
+
+	kfree(macstr);
+	return 0;
+}
+
+static void unregister_hotplug_status_watch(struct backend_info *be)
+{
+	if (be->have_hotplug_status_watch) {
+		unregister_xenbus_watch(&be->hotplug_status_watch);
+		kfree(be->hotplug_status_watch.node);
+	}
+	be->have_hotplug_status_watch =3D 0;
+}
+
+static void hotplug_status_changed(struct xenbus_watch *watch,
+				   const char **vec,
+				   unsigned int vec_size)
+{
+	struct backend_info *be =3D container_of(watch,
+					       struct backend_info,
+					       hotplug_status_watch);
+	char *str;
+	unsigned int len;
+
+	str =3D xenbus_read(XBT_NIL, be->dev->nodename, "hotplug-status", &le=
n);
+	if (IS_ERR(str))
+		return;
+	if (len =3D=3D sizeof("connected")-1 && !memcmp(str, "connected", len=
)) {
+		xenbus_switch_state(be->dev, XenbusStateConnected);
+		/* Not interested in this watch anymore. */
+		unregister_hotplug_status_watch(be);
+	}
+	kfree(str);
+}
+
+static void connect(struct backend_info *be)
+{
+	int err;
+	struct xenbus_device *dev =3D be->dev;
+
+	err =3D connect_rings(be);
+	if (err)
+		return;
+
+	err =3D xen_net_read_mac(dev, be->vif->fe_dev_addr);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
+		return;
+	}
+
+	xen_net_read_rate(dev, &be->vif->credit_bytes,
+			  &be->vif->credit_usec);
+	be->vif->remaining_credit =3D be->vif->credit_bytes;
+
+	unregister_hotplug_status_watch(be);
+	err =3D xenbus_watch_pathfmt(dev, &be->hotplug_status_watch,
+				   hotplug_status_changed,
+				   "%s/%s", dev->nodename, "hotplug-status");
+	if (err) {
+		/* Switch now, since we can't do a watch. */
+		xenbus_switch_state(dev, XenbusStateConnected);
+	} else {
+		be->have_hotplug_status_watch =3D 1;
+	}
+
+	netif_wake_queue(be->vif->dev);
+}
+
+
+static int connect_rings(struct backend_info *be)
+{
+	struct xenvif *vif =3D be->vif;
+	struct xenbus_device *dev =3D be->dev;
+	unsigned long tx_ring_ref, rx_ring_ref;
+	unsigned int evtchn, rx_copy;
+	int err;
+	int val;
+
+	err =3D xenbus_gather(XBT_NIL, dev->otherend,
+			    "tx-ring-ref", "%lu", &tx_ring_ref,
+			    "rx-ring-ref", "%lu", &rx_ring_ref,
+			    "event-channel", "%u", &evtchn, NULL);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "reading %s/ring-ref and event-channel",
+				 dev->otherend);
+		return err;
+	}
+
+	err =3D xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
+			   &rx_copy);
+	if (err =3D=3D -ENOENT) {
+		err =3D 0;
+		rx_copy =3D 0;
+	}
+	if (err < 0) {
+		xenbus_dev_fatal(dev, err, "reading %s/request-rx-copy",
+				 dev->otherend);
+		return err;
+	}
+	if (!rx_copy)
+		return -EOPNOTSUPP;
+
+	if (vif->dev->tx_queue_len !=3D 0) {
+		if (xenbus_scanf(XBT_NIL, dev->otherend,
+				 "feature-rx-notify", "%d", &val) < 0)
+			val =3D 0;
+		if (val)
+			vif->can_queue =3D 1;
+		else
+			/* Must be non-zero for pfifo_fast to work. */
+			vif->dev->tx_queue_len =3D 1;
+	}
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
+			 "%d", &val) < 0)
+		val =3D 0;
+	vif->can_sg =3D !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
+			 "%d", &val) < 0)
+		val =3D 0;
+	vif->gso =3D !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
+			 "%d", &val) < 0)
+		val =3D 0;
+	vif->gso_prefix =3D !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
+			 "%d", &val) < 0)
+		val =3D 0;
+	vif->csum =3D !val;
+
+	/* Map the shared frame, irq etc. */
+	err =3D xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "mapping shared-frames %lu/%lu port %u",
+				 tx_ring_ref, rx_ring_ref, evtchn);
+		return err;
+	}
+	return 0;
+}
+
+
+/* ** Driver Registration ** */
+
+
+static const struct xenbus_device_id netback_ids[] =3D {
+	{ "vif" },
+	{ "" }
+};
+
+
+static struct xenbus_driver netback =3D {
+	.name =3D "vif",
+	.owner =3D THIS_MODULE,
+	.ids =3D netback_ids,
+	.probe =3D netback_probe,
+	.remove =3D netback_remove,
+	.uevent =3D netback_uevent,
+	.otherend_changed =3D frontend_changed,
+};
+
+int xenvif_xenbus_init(void)
+{
+	return xenbus_register_backend(&netback);
+}
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 546de57..31c1e78 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -356,7 +356,7 @@ static void xennet_tx_buf_gc(struct net_device *dev=
)
 			struct xen_netif_tx_response *txrsp;
=20
 			txrsp =3D RING_GET_RESPONSE(&np->tx, cons);
-			if (txrsp->status =3D=3D NETIF_RSP_NULL)
+			if (txrsp->status =3D=3D XEN_NETIF_RSP_NULL)
 				continue;
=20
 			id  =3D txrsp->id;
@@ -413,7 +413,7 @@ static void xennet_make_frags(struct sk_buff *skb, =
struct net_device *dev,
 	   larger than a page), split it it into page-sized chunks. */
 	while (len > PAGE_SIZE - offset) {
 		tx->size =3D PAGE_SIZE - offset;
-		tx->flags |=3D NETTXF_more_data;
+		tx->flags |=3D XEN_NETTXF_more_data;
 		len -=3D tx->size;
 		data +=3D tx->size;
 		offset =3D 0;
@@ -439,7 +439,7 @@ static void xennet_make_frags(struct sk_buff *skb, =
struct net_device *dev,
 	for (i =3D 0; i < frags; i++) {
 		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
=20
-		tx->flags |=3D NETTXF_more_data;
+		tx->flags |=3D XEN_NETTXF_more_data;
=20
 		id =3D get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
 		np->tx_skbs[id].skb =3D skb_get(skb);
@@ -514,10 +514,10 @@ static int xennet_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 	tx->flags =3D 0;
 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
 		/* local packet? */
-		tx->flags |=3D NETTXF_csum_blank | NETTXF_data_validated;
+		tx->flags |=3D XEN_NETTXF_csum_blank | XEN_NETTXF_data_validated;
 	else if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
 		/* remote but checksummed. */
-		tx->flags |=3D NETTXF_data_validated;
+		tx->flags |=3D XEN_NETTXF_data_validated;
=20
 	if (skb_shinfo(skb)->gso_size) {
 		struct xen_netif_extra_info *gso;
@@ -528,7 +528,7 @@ static int xennet_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 		if (extra)
 			extra->flags |=3D XEN_NETIF_EXTRA_FLAG_MORE;
 		else
-			tx->flags |=3D NETTXF_extra_info;
+			tx->flags |=3D XEN_NETTXF_extra_info;
=20
 		gso->u.gso.size =3D skb_shinfo(skb)->gso_size;
 		gso->u.gso.type =3D XEN_NETIF_GSO_TYPE_TCPV4;
@@ -648,7 +648,7 @@ static int xennet_get_responses(struct netfront_inf=
o *np,
 	int err =3D 0;
 	unsigned long ret;
=20
-	if (rx->flags & NETRXF_extra_info) {
+	if (rx->flags & XEN_NETRXF_extra_info) {
 		err =3D xennet_get_extras(np, extras, rp);
 		cons =3D np->rx.rsp_cons;
 	}
@@ -685,7 +685,7 @@ static int xennet_get_responses(struct netfront_inf=
o *np,
 		__skb_queue_tail(list, skb);
=20
 next:
-		if (!(rx->flags & NETRXF_more_data))
+		if (!(rx->flags & XEN_NETRXF_more_data))
 			break;
=20
 		if (cons + frags =3D=3D rp) {
@@ -950,9 +950,9 @@ err:
 		skb->truesize +=3D skb->data_len - (RX_COPY_THRESHOLD - len);
 		skb->len +=3D skb->data_len;
=20
-		if (rx->flags & NETRXF_csum_blank)
+		if (rx->flags & XEN_NETRXF_csum_blank)
 			skb->ip_summed =3D CHECKSUM_PARTIAL;
-		else if (rx->flags & NETRXF_data_validated)
+		else if (rx->flags & XEN_NETRXF_data_validated)
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 		__skb_queue_tail(&rxq, skb);
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/i=
o/netif.h
index 518481c..cb94668 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -22,50 +22,50 @@
=20
 /*
  * This is the 'wire' format for packets:
- *  Request 1: netif_tx_request -- NETTXF_* (any flags)
- * [Request 2: netif_tx_extra]  (only if request 1 has NETTXF_extra_in=
fo)
- * [Request 3: netif_tx_extra]  (only if request 2 has XEN_NETIF_EXTRA=
_MORE)
- *  Request 4: netif_tx_request -- NETTXF_more_data
- *  Request 5: netif_tx_request -- NETTXF_more_data
+ *  Request 1: xen_netif_tx_request  -- XEN_NETTXF_* (any flags)
+ * [Request 2: xen_netif_extra_info]    (only if request 1 has XEN_NET=
TXF_extra_info)
+ * [Request 3: xen_netif_extra_info]    (only if request 2 has XEN_NET=
IF_EXTRA_MORE)
+ *  Request 4: xen_netif_tx_request  -- XEN_NETTXF_more_data
+ *  Request 5: xen_netif_tx_request  -- XEN_NETTXF_more_data
  *  ...
- *  Request N: netif_tx_request -- 0
+ *  Request N: xen_netif_tx_request  -- 0
  */
=20
 /* Protocol checksum field is blank in the packet (hardware offload)? =
*/
-#define _NETTXF_csum_blank     (0)
-#define  NETTXF_csum_blank     (1U<<_NETTXF_csum_blank)
+#define _XEN_NETTXF_csum_blank		(0)
+#define  XEN_NETTXF_csum_blank		(1U<<_XEN_NETTXF_csum_blank)
=20
 /* Packet data has been validated against protocol checksum. */
-#define _NETTXF_data_validated (1)
-#define  NETTXF_data_validated (1U<<_NETTXF_data_validated)
+#define _XEN_NETTXF_data_validated	(1)
+#define  XEN_NETTXF_data_validated	(1U<<_XEN_NETTXF_data_validated)
=20
 /* Packet continues in the next request descriptor. */
-#define _NETTXF_more_data      (2)
-#define  NETTXF_more_data      (1U<<_NETTXF_more_data)
+#define _XEN_NETTXF_more_data		(2)
+#define  XEN_NETTXF_more_data		(1U<<_XEN_NETTXF_more_data)
=20
 /* Packet to be followed by extra descriptor(s). */
-#define _NETTXF_extra_info     (3)
-#define  NETTXF_extra_info     (1U<<_NETTXF_extra_info)
+#define _XEN_NETTXF_extra_info		(3)
+#define  XEN_NETTXF_extra_info		(1U<<_XEN_NETTXF_extra_info)
=20
 struct xen_netif_tx_request {
     grant_ref_t gref;      /* Reference to buffer page */
     uint16_t offset;       /* Offset within buffer page */
-    uint16_t flags;        /* NETTXF_* */
+    uint16_t flags;        /* XEN_NETTXF_* */
     uint16_t id;           /* Echoed in response message. */
     uint16_t size;         /* Packet size in bytes.       */
 };
=20
-/* Types of netif_extra_info descriptors. */
-#define XEN_NETIF_EXTRA_TYPE_NONE  (0)  /* Never used - invalid */
-#define XEN_NETIF_EXTRA_TYPE_GSO   (1)  /* u.gso */
-#define XEN_NETIF_EXTRA_TYPE_MAX   (2)
+/* Types of xen_netif_extra_info descriptors. */
+#define XEN_NETIF_EXTRA_TYPE_NONE	(0)  /* Never used - invalid */
+#define XEN_NETIF_EXTRA_TYPE_GSO	(1)  /* u.gso */
+#define XEN_NETIF_EXTRA_TYPE_MAX	(2)
=20
-/* netif_extra_info flags. */
-#define _XEN_NETIF_EXTRA_FLAG_MORE (0)
-#define XEN_NETIF_EXTRA_FLAG_MORE  (1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
+/* xen_netif_extra_info flags. */
+#define _XEN_NETIF_EXTRA_FLAG_MORE	(0)
+#define  XEN_NETIF_EXTRA_FLAG_MORE	(1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
=20
 /* GSO types - only TCPv4 currently supported. */
-#define XEN_NETIF_GSO_TYPE_TCPV4        (1)
+#define XEN_NETIF_GSO_TYPE_TCPV4	(1)
=20
 /*
  * This structure needs to fit within both netif_tx_request and
@@ -107,7 +107,7 @@ struct xen_netif_extra_info {
=20
 struct xen_netif_tx_response {
 	uint16_t id;
-	int16_t  status;       /* NETIF_RSP_* */
+	int16_t  status;       /* XEN_NETIF_RSP_* */
 };
=20
 struct xen_netif_rx_request {
@@ -116,25 +116,29 @@ struct xen_netif_rx_request {
 };
=20
 /* Packet data has been validated against protocol checksum. */
-#define _NETRXF_data_validated (0)
-#define  NETRXF_data_validated (1U<<_NETRXF_data_validated)
+#define _XEN_NETRXF_data_validated	(0)
+#define  XEN_NETRXF_data_validated	(1U<<_XEN_NETRXF_data_validated)
=20
 /* Protocol checksum field is blank in the packet (hardware offload)? =
*/
-#define _NETRXF_csum_blank     (1)
-#define  NETRXF_csum_blank     (1U<<_NETRXF_csum_blank)
+#define _XEN_NETRXF_csum_blank		(1)
+#define  XEN_NETRXF_csum_blank		(1U<<_XEN_NETRXF_csum_blank)
=20
 /* Packet continues in the next request descriptor. */
-#define _NETRXF_more_data      (2)
-#define  NETRXF_more_data      (1U<<_NETRXF_more_data)
+#define _XEN_NETRXF_more_data		(2)
+#define  XEN_NETRXF_more_data		(1U<<_XEN_NETRXF_more_data)
=20
 /* Packet to be followed by extra descriptor(s). */
-#define _NETRXF_extra_info     (3)
-#define  NETRXF_extra_info     (1U<<_NETRXF_extra_info)
+#define _XEN_NETRXF_extra_info		(3)
+#define  XEN_NETRXF_extra_info		(1U<<_XEN_NETRXF_extra_info)
+
+/* GSO Prefix descriptor. */
+#define _XEN_NETRXF_gso_prefix		(4)
+#define  XEN_NETRXF_gso_prefix		(1U<<_XEN_NETRXF_gso_prefix)
=20
 struct xen_netif_rx_response {
     uint16_t id;
     uint16_t offset;       /* Offset in page of start of received pack=
et  */
-    uint16_t flags;        /* NETRXF_* */
+    uint16_t flags;        /* XEN_NETRXF_* */
     int16_t  status;       /* -ve: BLKIF_RSP_* ; +ve: Rx'ed pkt size. =
*/
 };
=20
@@ -149,10 +153,10 @@ DEFINE_RING_TYPES(xen_netif_rx,
 		  struct xen_netif_rx_request,
 		  struct xen_netif_rx_response);
=20
-#define NETIF_RSP_DROPPED         -2
-#define NETIF_RSP_ERROR           -1
-#define NETIF_RSP_OKAY             0
-/* No response: used for auxiliary requests (e.g., netif_tx_extra). */
-#define NETIF_RSP_NULL             1
+#define XEN_NETIF_RSP_DROPPED	-2
+#define XEN_NETIF_RSP_ERROR	-1
+#define XEN_NETIF_RSP_OKAY	 0
+/* No response: used for auxiliary requests (e.g., xen_netif_extra_inf=
o). */
+#define XEN_NETIF_RSP_NULL	 1
=20
 #endif



