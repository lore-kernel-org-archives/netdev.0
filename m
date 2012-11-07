From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/4] UAPI: (Scripted) Disintegrate include/linux/hdlc
Date: Wed, 07 Nov 2012 12:37:17 +0000
Message-ID: <20121107123717.4147.15213.stgit@warthog.procyon.org.uk>
References: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab2KGMh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2012 07:37:29 -0500
In-Reply-To: <20121107123709.4147.98018.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Acked-by: Dave Jones <davej@redhat.com>
Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
---

 include/linux/hdlc/Kbuild       |    1 
 include/linux/hdlc/ioctl.h      |   81 ---------------------------------------
 include/uapi/linux/hdlc/Kbuild  |    1 
 include/uapi/linux/hdlc/ioctl.h |   81 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 82 insertions(+), 82 deletions(-)
 delete mode 100644 include/linux/hdlc/ioctl.h
 create mode 100644 include/uapi/linux/hdlc/ioctl.h

diff --git a/include/linux/hdlc/Kbuild b/include/linux/hdlc/Kbuild
index 1fb2644..e69de29 100644
--- a/include/linux/hdlc/Kbuild
+++ b/include/linux/hdlc/Kbuild
@@ -1 +0,0 @@
-header-y += ioctl.h
diff --git a/include/linux/hdlc/ioctl.h b/include/linux/hdlc/ioctl.h
deleted file mode 100644
index 5839723..0000000
--- a/include/linux/hdlc/ioctl.h
+++ /dev/null
@@ -1,81 +0,0 @@
-#ifndef __HDLC_IOCTL_H__
-#define __HDLC_IOCTL_H__
-
-
-#define GENERIC_HDLC_VERSION 4	/* For synchronization with sethdlc utility */
-
-#define CLOCK_DEFAULT   0	/* Default setting */
-#define CLOCK_EXT	1	/* External TX and RX clock - DTE */
-#define CLOCK_INT	2	/* Internal TX and RX clock - DCE */
-#define CLOCK_TXINT	3	/* Internal TX and external RX clock */
-#define CLOCK_TXFROMRX	4	/* TX clock derived from external RX clock */
-
-
-#define ENCODING_DEFAULT	0 /* Default setting */
-#define ENCODING_NRZ		1
-#define ENCODING_NRZI		2
-#define ENCODING_FM_MARK	3
-#define ENCODING_FM_SPACE	4
-#define ENCODING_MANCHESTER	5
-
-
-#define PARITY_DEFAULT		0 /* Default setting */
-#define PARITY_NONE		1 /* No parity */
-#define PARITY_CRC16_PR0	2 /* CRC16, initial value 0x0000 */
-#define PARITY_CRC16_PR1	3 /* CRC16, initial value 0xFFFF */
-#define PARITY_CRC16_PR0_CCITT	4 /* CRC16, initial 0x0000, ITU-T version */
-#define PARITY_CRC16_PR1_CCITT	5 /* CRC16, initial 0xFFFF, ITU-T version */
-#define PARITY_CRC32_PR0_CCITT	6 /* CRC32, initial value 0x00000000 */
-#define PARITY_CRC32_PR1_CCITT	7 /* CRC32, initial value 0xFFFFFFFF */
-
-#define LMI_DEFAULT		0 /* Default setting */
-#define LMI_NONE		1 /* No LMI, all PVCs are static */
-#define LMI_ANSI		2 /* ANSI Annex D */
-#define LMI_CCITT		3 /* ITU-T Annex A */
-#define LMI_CISCO		4 /* The "original" LMI, aka Gang of Four */
-
-typedef struct { 
-	unsigned int clock_rate; /* bits per second */
-	unsigned int clock_type; /* internal, external, TX-internal etc. */
-	unsigned short loopback;
-} sync_serial_settings;          /* V.35, V.24, X.21 */
-
-typedef struct { 
-	unsigned int clock_rate; /* bits per second */
-	unsigned int clock_type; /* internal, external, TX-internal etc. */
-	unsigned short loopback;
-	unsigned int slot_map;
-} te1_settings;                  /* T1, E1 */
-
-typedef struct {
-	unsigned short encoding;
-	unsigned short parity;
-} raw_hdlc_proto;
-
-typedef struct {
-	unsigned int t391;
-	unsigned int t392;
-	unsigned int n391;
-	unsigned int n392;
-	unsigned int n393;
-	unsigned short lmi;
-	unsigned short dce; /* 1 for DCE (network side) operation */
-} fr_proto;
-
-typedef struct {
-	unsigned int dlci;
-} fr_proto_pvc;          /* for creating/deleting FR PVCs */
-
-typedef struct {
-	unsigned int dlci;
-	char master[IFNAMSIZ];	/* Name of master FRAD device */
-}fr_proto_pvc_info;		/* for returning PVC information only */
-
-typedef struct {
-    unsigned int interval;
-    unsigned int timeout;
-} cisco_proto;
-
-/* PPP doesn't need any info now - supply length = 0 to ioctl */
-
-#endif /* __HDLC_IOCTL_H__ */
diff --git a/include/uapi/linux/hdlc/Kbuild b/include/uapi/linux/hdlc/Kbuild
index aafaa5a..8c1d2cb 100644
--- a/include/uapi/linux/hdlc/Kbuild
+++ b/include/uapi/linux/hdlc/Kbuild
@@ -1 +1,2 @@
 # UAPI Header export list
+header-y += ioctl.h
diff --git a/include/uapi/linux/hdlc/ioctl.h b/include/uapi/linux/hdlc/ioctl.h
new file mode 100644
index 0000000..5839723
--- /dev/null
+++ b/include/uapi/linux/hdlc/ioctl.h
@@ -0,0 +1,81 @@
+#ifndef __HDLC_IOCTL_H__
+#define __HDLC_IOCTL_H__
+
+
+#define GENERIC_HDLC_VERSION 4	/* For synchronization with sethdlc utility */
+
+#define CLOCK_DEFAULT   0	/* Default setting */
+#define CLOCK_EXT	1	/* External TX and RX clock - DTE */
+#define CLOCK_INT	2	/* Internal TX and RX clock - DCE */
+#define CLOCK_TXINT	3	/* Internal TX and external RX clock */
+#define CLOCK_TXFROMRX	4	/* TX clock derived from external RX clock */
+
+
+#define ENCODING_DEFAULT	0 /* Default setting */
+#define ENCODING_NRZ		1
+#define ENCODING_NRZI		2
+#define ENCODING_FM_MARK	3
+#define ENCODING_FM_SPACE	4
+#define ENCODING_MANCHESTER	5
+
+
+#define PARITY_DEFAULT		0 /* Default setting */
+#define PARITY_NONE		1 /* No parity */
+#define PARITY_CRC16_PR0	2 /* CRC16, initial value 0x0000 */
+#define PARITY_CRC16_PR1	3 /* CRC16, initial value 0xFFFF */
+#define PARITY_CRC16_PR0_CCITT	4 /* CRC16, initial 0x0000, ITU-T version */
+#define PARITY_CRC16_PR1_CCITT	5 /* CRC16, initial 0xFFFF, ITU-T version */
+#define PARITY_CRC32_PR0_CCITT	6 /* CRC32, initial value 0x00000000 */
+#define PARITY_CRC32_PR1_CCITT	7 /* CRC32, initial value 0xFFFFFFFF */
+
+#define LMI_DEFAULT		0 /* Default setting */
+#define LMI_NONE		1 /* No LMI, all PVCs are static */
+#define LMI_ANSI		2 /* ANSI Annex D */
+#define LMI_CCITT		3 /* ITU-T Annex A */
+#define LMI_CISCO		4 /* The "original" LMI, aka Gang of Four */
+
+typedef struct { 
+	unsigned int clock_rate; /* bits per second */
+	unsigned int clock_type; /* internal, external, TX-internal etc. */
+	unsigned short loopback;
+} sync_serial_settings;          /* V.35, V.24, X.21 */
+
+typedef struct { 
+	unsigned int clock_rate; /* bits per second */
+	unsigned int clock_type; /* internal, external, TX-internal etc. */
+	unsigned short loopback;
+	unsigned int slot_map;
+} te1_settings;                  /* T1, E1 */
+
+typedef struct {
+	unsigned short encoding;
+	unsigned short parity;
+} raw_hdlc_proto;
+
+typedef struct {
+	unsigned int t391;
+	unsigned int t392;
+	unsigned int n391;
+	unsigned int n392;
+	unsigned int n393;
+	unsigned short lmi;
+	unsigned short dce; /* 1 for DCE (network side) operation */
+} fr_proto;
+
+typedef struct {
+	unsigned int dlci;
+} fr_proto_pvc;          /* for creating/deleting FR PVCs */
+
+typedef struct {
+	unsigned int dlci;
+	char master[IFNAMSIZ];	/* Name of master FRAD device */
+}fr_proto_pvc_info;		/* for returning PVC information only */
+
+typedef struct {
+    unsigned int interval;
+    unsigned int timeout;
+} cisco_proto;
+
+/* PPP doesn't need any info now - supply length = 0 to ioctl */
+
+#endif /* __HDLC_IOCTL_H__ */
