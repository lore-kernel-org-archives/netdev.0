From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH 2/3] ppp: Move ioctl definitions from if_ppp.h to new
 ppp-ioctl.h
Date: Mon, 5 Mar 2012 09:56:04 +1100
Message-ID: <20120304225603.GC10646@bloggs.ozlabs.ibm.com>
References: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kiszka <jan.kiszka@siemens.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This moves the definitions of the ioctls, constants and structures
relating to the ppp_generic interface to userspace out from if_ppp.h
to a new file, ppp-ioctl.h.  The new file has my copyright since I
designed and implemented the ppp_generic interface in the late 1990s.
None of the contents of this file comes from the original if_ppp.h
published by Carnegie Mellon University.

Of the remainder of if_ppp.h, only the PPP_MTU definition was being
used, and this replaces the uses of it with PPP_MRU (which is identical).
Therefore, this replaces the entire file with the single line

#include <linux/ppp-ioctl.h>

which clearly doesn't contain any CMU code.  Thus I have removed the
CMU copyright notice with its problematic advertising clause, and in
fact since it's only one trivial line I have not added any other
copyright notice.

Signed-off-by: Paul Mackerras <paulus@samba.org>
---
 Documentation/ioctl/ioctl-number.txt     |    2 +-
 Documentation/networking/ppp_generic.txt |    6 +-
 drivers/net/ppp/ppp_generic.c            |    4 +-
 drivers/net/ppp/pptp.c                   |    4 +-
 include/linux/Kbuild                     |    1 +
 include/linux/if_ppp.h                   |  174 +-----------------------------
 include/linux/ppp-ioctl.h                |  119 ++++++++++++++++++++
 7 files changed, 129 insertions(+), 181 deletions(-)
 create mode 100644 include/linux/ppp-ioctl.h

diff --git a/Documentation/ioctl/ioctl-number.txt b/Documentation/ioctl/ioctl-number.txt
index 4840334..85af548 100644
--- a/Documentation/ioctl/ioctl-number.txt
+++ b/Documentation/ioctl/ioctl-number.txt
@@ -255,7 +255,7 @@ Code  Seq#(hex)	Include File		Comments
 		linux/ixjuser.h		<http://web.archive.org/web/*/http://www.quicknet.net>
 'r'	00-1F	linux/msdos_fs.h and fs/fat/dir.c
 's'	all	linux/cdk.h
-'t'	00-7F	linux/if_ppp.h
+'t'	00-7F	linux/ppp-ioctl.h
 't'	80-8F	linux/isdn_ppp.h
 't'	90	linux/toshiba.h
 'u'	00-1F	linux/smb_fs.h		gone
diff --git a/Documentation/networking/ppp_generic.txt b/Documentation/networking/ppp_generic.txt
index 15b5172..091d202 100644
--- a/Documentation/networking/ppp_generic.txt
+++ b/Documentation/networking/ppp_generic.txt
@@ -342,7 +342,7 @@ an interface unit are:
 				numbers on received multilink fragments
 	SC_MP_XSHORTSEQ		transmit short multilink sequence nos.
 
-  The values of these flags are defined in <linux/if_ppp.h>.  Note
+  The values of these flags are defined in <linux/ppp-ioctl.h>.  Note
   that the values of the SC_MULTILINK, SC_MP_SHORTSEQ and
   SC_MP_XSHORTSEQ bits are ignored if the CONFIG_PPP_MULTILINK option
   is not selected.
@@ -358,7 +358,7 @@ an interface unit are:
 
 * PPPIOCSCOMPRESS sets the parameters for packet compression or
   decompression.  The argument should point to a ppp_option_data
-  structure (defined in <linux/if_ppp.h>), which contains a
+  structure (defined in <linux/ppp-ioctl.h>), which contains a
   pointer/length pair which should describe a block of memory
   containing a CCP option specifying a compression method and its
   parameters.  The ppp_option_data struct also contains a `transmit'
@@ -395,7 +395,7 @@ an interface unit are:
 
 * PPPIOCSNPMODE sets the network-protocol mode for a given network
   protocol.  The argument should point to an npioctl struct (defined
-  in <linux/if_ppp.h>).  The `protocol' field gives the PPP protocol
+  in <linux/ppp-ioctl.h>).  The `protocol' field gives the PPP protocol
   number for the protocol to be affected, and the `mode' field
   specifies what to do with packets for that protocol:
 
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index edfa15d..52e4361 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -32,7 +32,7 @@
 #include <linux/poll.h>
 #include <linux/ppp_defs.h>
 #include <linux/filter.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/ppp_channel.h>
 #include <linux/ppp-comp.h>
 #include <linux/skbuff.h>
@@ -1031,7 +1031,7 @@ static void ppp_setup(struct net_device *dev)
 {
 	dev->netdev_ops = &ppp_netdev_ops;
 	dev->hard_header_len = PPP_HDRLEN;
-	dev->mtu = PPP_MTU;
+	dev->mtu = PPP_MRU;
 	dev->addr_len = 0;
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index df884dd..3b9f04c 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -23,7 +23,7 @@
 #include <linux/ppp_channel.h>
 #include <linux/ppp_defs.h>
 #include <linux/if_pppox.h>
-#include <linux/if_ppp.h>
+#include <linux/ppp-ioctl.h>
 #include <linux/notifier.h>
 #include <linux/file.h>
 #include <linux/in.h>
@@ -481,7 +481,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	po->chan.mtu = dst_mtu(&rt->dst);
 	if (!po->chan.mtu)
-		po->chan.mtu = PPP_MTU;
+		po->chan.mtu = PPP_MRU;
 	ip_rt_put(rt);
 	po->chan.mtu -= PPTP_HEADER_OVERHEAD;
 
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index c94e717..273a9c7 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -304,6 +304,7 @@ header-y += poll.h
 header-y += posix_types.h
 header-y += ppdev.h
 header-y += ppp-comp.h
+header-y += ppp-ioctl.h
 header-y += ppp_defs.h
 header-y += pps.h
 header-y += prctl.h
diff --git a/include/linux/if_ppp.h b/include/linux/if_ppp.h
index c9ad383..9048fab 100644
--- a/include/linux/if_ppp.h
+++ b/include/linux/if_ppp.h
@@ -1,173 +1 @@
-/*
- * if_ppp.h - Point-to-Point Protocol definitions.
- *
- * Copyright (c) 1989 Carnegie Mellon University.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms are permitted
- * provided that the above copyright notice and this paragraph are
- * duplicated in all such forms and that any documentation,
- * advertising materials, and other materials related to such
- * distribution and use acknowledge that the software was developed
- * by Carnegie Mellon University.  The name of the
- * University may not be used to endorse or promote products derived
- * from this software without specific prior written permission.
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
- * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
- *
- */
-
-/*
- *  ==FILEVERSION 20050812==
- *
- *  NOTE TO MAINTAINERS:
- *     If you modify this file at all, please set the above date.
- *     if_ppp.h is shipped with a PPP distribution as well as with the kernel;
- *     if everyone increases the FILEVERSION number above, then scripts
- *     can do the right thing when deciding whether to install a new if_ppp.h
- *     file.  Don't change the format of that line otherwise, so the
- *     installation script can recognize it.
- */
-
-#ifndef _IF_PPP_H_
-#define _IF_PPP_H_
-
-#include <linux/types.h>
-#include <linux/compiler.h>
-
-/*
- * Packet sizes
- */
-
-#define	PPP_MTU		1500	/* Default MTU (size of Info field) */
-#define PPP_MAXMRU	65000	/* Largest MRU we allow */
-#define PROTO_IPX	0x002b	/* protocol numbers */
-#define PROTO_DNA_RT    0x0027  /* DNA Routing */
-
-
-/*
- * Bit definitions for flags.
- */
-
-#define SC_COMP_PROT	0x00000001	/* protocol compression (output) */
-#define SC_COMP_AC	0x00000002	/* header compression (output) */
-#define	SC_COMP_TCP	0x00000004	/* TCP (VJ) compression (output) */
-#define SC_NO_TCP_CCID	0x00000008	/* disable VJ connection-id comp. */
-#define SC_REJ_COMP_AC	0x00000010	/* reject adrs/ctrl comp. on input */
-#define SC_REJ_COMP_TCP	0x00000020	/* reject TCP (VJ) comp. on input */
-#define SC_CCP_OPEN	0x00000040	/* Look at CCP packets */
-#define SC_CCP_UP	0x00000080	/* May send/recv compressed packets */
-#define SC_ENABLE_IP	0x00000100	/* IP packets may be exchanged */
-#define SC_LOOP_TRAFFIC	0x00000200	/* send traffic to pppd */
-#define SC_MULTILINK	0x00000400	/* do multilink encapsulation */
-#define SC_MP_SHORTSEQ	0x00000800	/* use short MP sequence numbers */
-#define SC_COMP_RUN	0x00001000	/* compressor has been inited */
-#define SC_DECOMP_RUN	0x00002000	/* decompressor has been inited */
-#define SC_MP_XSHORTSEQ	0x00004000	/* transmit short MP seq numbers */
-#define SC_DEBUG	0x00010000	/* enable debug messages */
-#define SC_LOG_INPKT	0x00020000	/* log contents of good pkts recvd */
-#define SC_LOG_OUTPKT	0x00040000	/* log contents of pkts sent */
-#define SC_LOG_RAWIN	0x00080000	/* log all chars received */
-#define SC_LOG_FLUSH	0x00100000	/* log all chars flushed */
-#define	SC_SYNC		0x00200000	/* synchronous serial mode */
-#define	SC_MUST_COMP    0x00400000	/* no uncompressed packets may be sent or received */
-#define	SC_MASK		0x0f600fff	/* bits that user can change */
-
-/* state bits */
-#define SC_XMIT_BUSY	0x10000000	/* (used by isdn_ppp?) */
-#define SC_RCV_ODDP	0x08000000	/* have rcvd char with odd parity */
-#define SC_RCV_EVNP	0x04000000	/* have rcvd char with even parity */
-#define SC_RCV_B7_1	0x02000000	/* have rcvd char with bit 7 = 1 */
-#define SC_RCV_B7_0	0x01000000	/* have rcvd char with bit 7 = 0 */
-#define SC_DC_FERROR	0x00800000	/* fatal decomp error detected */
-#define SC_DC_ERROR	0x00400000	/* non-fatal decomp error detected */
-
-/*
- * Ioctl definitions.
- */
-
-struct npioctl {
-	int		protocol;	/* PPP protocol, e.g. PPP_IP */
-	enum NPmode	mode;
-};
-
-/* Structure describing a CCP configuration option, for PPPIOCSCOMPRESS */
-struct ppp_option_data {
-	__u8	__user *ptr;
-	__u32	length;
-	int	transmit;
-};
-
-struct ifpppstatsreq {
-	struct ifreq	 b;
-	struct ppp_stats stats;			/* statistic information */
-};
-
-struct ifpppcstatsreq {
-	struct ifreq	      b;
-	struct ppp_comp_stats stats;
-};
-
-/* For PPPIOCGL2TPSTATS */
-struct pppol2tp_ioc_stats {
-	__u16		tunnel_id;	/* redundant */
-	__u16		session_id;	/* if zero, get tunnel stats */
-	__u32		using_ipsec:1;	/* valid only for session_id == 0 */
-	__aligned_u64	tx_packets;
-	__aligned_u64	tx_bytes;
-	__aligned_u64	tx_errors;
-	__aligned_u64	rx_packets;
-	__aligned_u64	rx_bytes;
-	__aligned_u64	rx_seq_discards;
-	__aligned_u64	rx_oos_packets;
-	__aligned_u64	rx_errors;
-};
-
-#define ifr__name       b.ifr_ifrn.ifrn_name
-#define stats_ptr       b.ifr_ifru.ifru_data
-
-/*
- * Ioctl definitions.
- */
-
-#define	PPPIOCGFLAGS	_IOR('t', 90, int)	/* get configuration flags */
-#define	PPPIOCSFLAGS	_IOW('t', 89, int)	/* set configuration flags */
-#define	PPPIOCGASYNCMAP	_IOR('t', 88, int)	/* get async map */
-#define	PPPIOCSASYNCMAP	_IOW('t', 87, int)	/* set async map */
-#define	PPPIOCGUNIT	_IOR('t', 86, int)	/* get ppp unit number */
-#define	PPPIOCGRASYNCMAP _IOR('t', 85, int)	/* get receive async map */
-#define	PPPIOCSRASYNCMAP _IOW('t', 84, int)	/* set receive async map */
-#define	PPPIOCGMRU	_IOR('t', 83, int)	/* get max receive unit */
-#define	PPPIOCSMRU	_IOW('t', 82, int)	/* set max receive unit */
-#define	PPPIOCSMAXCID	_IOW('t', 81, int)	/* set VJ max slot ID */
-#define PPPIOCGXASYNCMAP _IOR('t', 80, ext_accm) /* get extended ACCM */
-#define PPPIOCSXASYNCMAP _IOW('t', 79, ext_accm) /* set extended ACCM */
-#define PPPIOCXFERUNIT	_IO('t', 78)		/* transfer PPP unit */
-#define PPPIOCSCOMPRESS	_IOW('t', 77, struct ppp_option_data)
-#define PPPIOCGNPMODE	_IOWR('t', 76, struct npioctl) /* get NP mode */
-#define PPPIOCSNPMODE	_IOW('t', 75, struct npioctl)  /* set NP mode */
-#define PPPIOCSPASS	_IOW('t', 71, struct sock_fprog) /* set pass filter */
-#define PPPIOCSACTIVE	_IOW('t', 70, struct sock_fprog) /* set active filt */
-#define PPPIOCGDEBUG	_IOR('t', 65, int)	/* Read debug level */
-#define PPPIOCSDEBUG	_IOW('t', 64, int)	/* Set debug level */
-#define PPPIOCGIDLE	_IOR('t', 63, struct ppp_idle) /* get idle time */
-#define PPPIOCNEWUNIT	_IOWR('t', 62, int)	/* create new ppp unit */
-#define PPPIOCATTACH	_IOW('t', 61, int)	/* attach to ppp unit */
-#define PPPIOCDETACH	_IOW('t', 60, int)	/* detach from ppp unit/chan */
-#define PPPIOCSMRRU	_IOW('t', 59, int)	/* set multilink MRU */
-#define PPPIOCCONNECT	_IOW('t', 58, int)	/* connect channel to unit */
-#define PPPIOCDISCONN	_IO('t', 57)		/* disconnect channel */
-#define PPPIOCATTCHAN	_IOW('t', 56, int)	/* attach to ppp channel */
-#define PPPIOCGCHAN	_IOR('t', 55, int)	/* get ppp channel number */
-#define PPPIOCGL2TPSTATS _IOR('t', 54, struct pppol2tp_ioc_stats)
-
-#define SIOCGPPPSTATS   (SIOCDEVPRIVATE + 0)
-#define SIOCGPPPVER     (SIOCDEVPRIVATE + 1)	/* NEVER change this!! */
-#define SIOCGPPPCSTATS  (SIOCDEVPRIVATE + 2)
-
-#if !defined(ifr_mtu)
-#define ifr_mtu	ifr_ifru.ifru_metric
-#endif
-
-#endif /* _IF_PPP_H_ */
+#include <linux/ppp-ioctl.h>
diff --git a/include/linux/ppp-ioctl.h b/include/linux/ppp-ioctl.h
new file mode 100644
index 0000000..2d9a885
--- /dev/null
+++ b/include/linux/ppp-ioctl.h
@@ -0,0 +1,119 @@
+/*
+ * ppp-ioctl.h - PPP ioctl definitions.
+ *
+ * Copyright 1999-2002 Paul Mackerras.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  version 2 as published by the Free Software Foundation.
+ */
+#ifndef _PPP_IOCTL_H
+#define _PPP_IOCTL_H
+
+#include <linux/types.h>
+#include <linux/compiler.h>
+
+/*
+ * Bit definitions for flags argument to PPPIOCGFLAGS/PPPIOCSFLAGS.
+ */
+#define SC_COMP_PROT	0x00000001	/* protocol compression (output) */
+#define SC_COMP_AC	0x00000002	/* header compression (output) */
+#define	SC_COMP_TCP	0x00000004	/* TCP (VJ) compression (output) */
+#define SC_NO_TCP_CCID	0x00000008	/* disable VJ connection-id comp. */
+#define SC_REJ_COMP_AC	0x00000010	/* reject adrs/ctrl comp. on input */
+#define SC_REJ_COMP_TCP	0x00000020	/* reject TCP (VJ) comp. on input */
+#define SC_CCP_OPEN	0x00000040	/* Look at CCP packets */
+#define SC_CCP_UP	0x00000080	/* May send/recv compressed packets */
+#define SC_ENABLE_IP	0x00000100	/* IP packets may be exchanged */
+#define SC_LOOP_TRAFFIC	0x00000200	/* send traffic to pppd */
+#define SC_MULTILINK	0x00000400	/* do multilink encapsulation */
+#define SC_MP_SHORTSEQ	0x00000800	/* use short MP sequence numbers */
+#define SC_COMP_RUN	0x00001000	/* compressor has been inited */
+#define SC_DECOMP_RUN	0x00002000	/* decompressor has been inited */
+#define SC_MP_XSHORTSEQ	0x00004000	/* transmit short MP seq numbers */
+#define SC_DEBUG	0x00010000	/* enable debug messages */
+#define SC_LOG_INPKT	0x00020000	/* log contents of good pkts recvd */
+#define SC_LOG_OUTPKT	0x00040000	/* log contents of pkts sent */
+#define SC_LOG_RAWIN	0x00080000	/* log all chars received */
+#define SC_LOG_FLUSH	0x00100000	/* log all chars flushed */
+#define	SC_SYNC		0x00200000	/* synchronous serial mode */
+#define	SC_MUST_COMP    0x00400000	/* no uncompressed packets may be sent or received */
+#define	SC_MASK		0x0f600fff	/* bits that user can change */
+
+/* state bits */
+#define SC_XMIT_BUSY	0x10000000	/* (used by isdn_ppp?) */
+#define SC_RCV_ODDP	0x08000000	/* have rcvd char with odd parity */
+#define SC_RCV_EVNP	0x04000000	/* have rcvd char with even parity */
+#define SC_RCV_B7_1	0x02000000	/* have rcvd char with bit 7 = 1 */
+#define SC_RCV_B7_0	0x01000000	/* have rcvd char with bit 7 = 0 */
+#define SC_DC_FERROR	0x00800000	/* fatal decomp error detected */
+#define SC_DC_ERROR	0x00400000	/* non-fatal decomp error detected */
+
+/* Used with PPPIOCGNPMODE/PPPIOCSNPMODE */
+struct npioctl {
+	int		protocol;	/* PPP protocol, e.g. PPP_IP */
+	enum NPmode	mode;
+};
+
+/* Structure describing a CCP configuration option, for PPPIOCSCOMPRESS */
+struct ppp_option_data {
+	__u8	__user *ptr;
+	__u32	length;
+	int	transmit;
+};
+
+/* For PPPIOCGL2TPSTATS */
+struct pppol2tp_ioc_stats {
+	__u16		tunnel_id;	/* redundant */
+	__u16		session_id;	/* if zero, get tunnel stats */
+	__u32		using_ipsec:1;	/* valid only for session_id == 0 */
+	__aligned_u64	tx_packets;
+	__aligned_u64	tx_bytes;
+	__aligned_u64	tx_errors;
+	__aligned_u64	rx_packets;
+	__aligned_u64	rx_bytes;
+	__aligned_u64	rx_seq_discards;
+	__aligned_u64	rx_oos_packets;
+	__aligned_u64	rx_errors;
+};
+
+/*
+ * Ioctl definitions.
+ */
+
+#define	PPPIOCGFLAGS	_IOR('t', 90, int)	/* get configuration flags */
+#define	PPPIOCSFLAGS	_IOW('t', 89, int)	/* set configuration flags */
+#define	PPPIOCGASYNCMAP	_IOR('t', 88, int)	/* get async map */
+#define	PPPIOCSASYNCMAP	_IOW('t', 87, int)	/* set async map */
+#define	PPPIOCGUNIT	_IOR('t', 86, int)	/* get ppp unit number */
+#define	PPPIOCGRASYNCMAP _IOR('t', 85, int)	/* get receive async map */
+#define	PPPIOCSRASYNCMAP _IOW('t', 84, int)	/* set receive async map */
+#define	PPPIOCGMRU	_IOR('t', 83, int)	/* get max receive unit */
+#define	PPPIOCSMRU	_IOW('t', 82, int)	/* set max receive unit */
+#define	PPPIOCSMAXCID	_IOW('t', 81, int)	/* set VJ max slot ID */
+#define PPPIOCGXASYNCMAP _IOR('t', 80, ext_accm) /* get extended ACCM */
+#define PPPIOCSXASYNCMAP _IOW('t', 79, ext_accm) /* set extended ACCM */
+#define PPPIOCXFERUNIT	_IO('t', 78)		/* transfer PPP unit */
+#define PPPIOCSCOMPRESS	_IOW('t', 77, struct ppp_option_data)
+#define PPPIOCGNPMODE	_IOWR('t', 76, struct npioctl) /* get NP mode */
+#define PPPIOCSNPMODE	_IOW('t', 75, struct npioctl)  /* set NP mode */
+#define PPPIOCSPASS	_IOW('t', 71, struct sock_fprog) /* set pass filter */
+#define PPPIOCSACTIVE	_IOW('t', 70, struct sock_fprog) /* set active filt */
+#define PPPIOCGDEBUG	_IOR('t', 65, int)	/* Read debug level */
+#define PPPIOCSDEBUG	_IOW('t', 64, int)	/* Set debug level */
+#define PPPIOCGIDLE	_IOR('t', 63, struct ppp_idle) /* get idle time */
+#define PPPIOCNEWUNIT	_IOWR('t', 62, int)	/* create new ppp unit */
+#define PPPIOCATTACH	_IOW('t', 61, int)	/* attach to ppp unit */
+#define PPPIOCDETACH	_IOW('t', 60, int)	/* detach from ppp unit/chan */
+#define PPPIOCSMRRU	_IOW('t', 59, int)	/* set multilink MRU */
+#define PPPIOCCONNECT	_IOW('t', 58, int)	/* connect channel to unit */
+#define PPPIOCDISCONN	_IO('t', 57)		/* disconnect channel */
+#define PPPIOCATTCHAN	_IOW('t', 56, int)	/* attach to ppp channel */
+#define PPPIOCGCHAN	_IOR('t', 55, int)	/* get ppp channel number */
+#define PPPIOCGL2TPSTATS _IOR('t', 54, struct pppol2tp_ioc_stats)
+
+#define SIOCGPPPSTATS   (SIOCDEVPRIVATE + 0)
+#define SIOCGPPPVER     (SIOCDEVPRIVATE + 1)	/* NEVER change this!! */
+#define SIOCGPPPCSTATS  (SIOCDEVPRIVATE + 2)
+
+#endif /* _PPP_IOCTL_H */
-- 
1.7.9.1
