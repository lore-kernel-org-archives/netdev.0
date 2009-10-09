From: sjur.brandeland@stericsson.com
Subject: [PATCH] [CAIF-RFC 1/8-v2] CAIF Protocol Stack
Date: Fri, 09 Oct 2009 15:39:24 +0200
Message-ID: <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:51694 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760786AbZJINlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:41:17 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR9002421YJVL90@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:39:55 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR900DNY1Y4LSP0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:39:55 +0200 (CEST)
In-reply-to: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Change-Id: I305056f116a11c31265f65ac0fe285e2b655dd54
Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_config.h |  203 ++++++++++++++++++++++++++++++++++++++
 include/linux/caif/caif_ioctl.h  |  113 +++++++++++++++++++++
 2 files changed, 316 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/caif/caif_config.h
 create mode 100644 include/linux/caif/caif_ioctl.h

diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
new file mode 100644
index 0000000..6ea934b
--- /dev/null
+++ b/include/linux/caif/caif_config.h
@@ -0,0 +1,203 @@
+/*
+ *	Copyright (C) ST-Ericsson AB 2009
+ *
+ *	CAIF Channel Configuration definitions.
+ *
+ *	Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+ *
+ *	License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+#ifndef CAIF_CONFIG_H_
+#define CAIF_CONFIG_H_
+
+/**
+ * enum caif_phy_preference -	Types of Physical HW Interfaces
+ *				towards modem defined in CAIF Stack,
+ * @CAIF_PHYPREF_UNSPECIFIED:	Default Physical Interface
+ * @CAIF_PHYPREF_LOW_LAT:	Default Physical Interface for Low Latency
+ *				Traffic
+ * @CAIF_PHYPREF_HIGH_BW:	Default Physical Interface for High Bandwidth
+ *				Traffic
+ * @_CAIF_PHYPREF_LOOP:		TEST Loop-back Interface Simulating Acc side
+ *				responses
+ * @_CAIF_PHYPREF_RAW_LOOP:	TEST ONLY Raw loopback interface
+ *
+ * For Client convenience to special types are defined:
+ * CAIF_PHYPREF_LOW_LAT is the preferred low latency physical link.
+ * Typically used for "control" purposes.
+ * CAIF_PHYPREF_HIGH_BW is the preferred high bandwidth physical link.
+ * Typically used for "payload" purposes.
+ *
+ */
+enum caif_phy_preference {
+	CAIF_PHYPREF_UNSPECIFIED	= 0x00,
+	CAIF_PHYPREF_LOW_LAT		= 0xd0,
+	CAIF_PHYPREF_HIGH_BW		= 0xe0,
+	_CAIF_PHYPREF_LOOP		= 0x70,
+	_CAIF_PHYPREF_RAW_LOOP		= 0x80
+};
+
+
+/*!
+ * define CAIF Channel Priority.
+ * Used when setting up a Channel to specify the
+ * priority level of the channel.
+ */
+
+#define CAIF_PRIO_UNSPCEIFIED  0x0
+#define CAIF_PRIO_MIN	       0x01	/*! Minimum Priority Level */
+#define CAIF_PRIO_LOW	       0x04	/*!< Suggested Priority Level for
+					 *   Low Priority Channel */
+#define CAIF_PRIO_NORMAL       0x0f	/*!< Suggested Normal/Default
+					 *   priority Level */
+#define CAIF_PRIO_HIGH	       0x14	/*!< Suggested High Priority Level */
+#define CAIF_PRIO_MAX	       0x1F	/*!< Max Priority for Channel
+					   (do not use)
+					 */
+
+/**
+ * enum caif_channel_type  Types of CAIF Channel type defined in CAIF Stack.
+ * @CAIF_CHTY_AT:		Classical AT
+ * @CAIF_CHTY_AT_CTRL:		AT Control only
+ * @CAIF_CHTY_AT_PAIRED:	Paired control and data
+ * @CAIF_CHTY_DATAGRAM:		Datagram, Requires: connection_id
+ * @CAIF_CHTY_DATAGRAM_LOOP:	Datagram Loopback (testing purposes only)
+ * @CAIF_CHTY_VIDEO:		Video Channel
+ * @CAIF_CHTY_DEBUG:		Debug Service (Debug Server and
+ *					       Interactive Debug)
+ * @CAIF_CHTY_DEBUG_TRACE:	Debug Server only
+ * @CAIF_CHTY_DEBUG_INTERACT:	Debug Interactive
+ * @CAIF_CHTY_RFM:		RFM Service. Params: connection_id, volume
+ * @CAIF_CHTY_UTILITY:		Utility (Psock) Service.
+ *				Params: fifo_kb,fifo_pkt, name, psock_param
+ * @CAIF_CHTY_RAW:		DO NOT USE. This is for testing only
+ *
+ * This is used for Channel Configuration specifying the type of channel.
+ */
+
+enum caif_channel_type {
+	CAIF_CHTY_AT,
+	CAIF_CHTY_AT_CTRL,
+	CAIF_CHTY_AT_PAIRED,
+	CAIF_CHTY_DATAGRAM,
+	CAIF_CHTY_DATAGRAM_LOOP,
+	CAIF_CHTY_VIDEO,
+	CAIF_CHTY_DEBUG,
+	CAIF_CHTY_DEBUG_TRACE,
+	CAIF_CHTY_DEBUG_INTERACT,
+	CAIF_CHTY_RFM,
+	CAIF_CHTY_UTILITY,
+	CAIF_CHTY_RAW
+};
+
+/**
+ *struct caif_channel_config This structures is used for configuring
+ *			     CAIF Channels.
+ * @name: Mandatory:	     Nickname for this device
+ * @type:		     Mandatory Define the type of caif service
+ * @priority:		     Mandatory Value between  CAIF_PRIO_MIN and
+ *			     CAIF_PRIO_MAX,
+ *			     CAIF_PRIO_LOW, CAIF_PRIO_NORMAL, CAIF_PRIO_HIGH
+ *			     are suggested values.
+ * @phy_pref:		     Either: Specify type of physical interface to use.
+ * @phy_name:		     Or: Specify identity of the physical interface.
+ *
+ * @u:			     Union of Channel Type Specific configuration
+ *			     parameters
+ *
+ * @u.dgm:		     CAIF_CHTYPE_DATAGRAM
+ * @u.dgm.connection_id:     Mandatory Connection ID must be specified.
+ *
+ * @u.video:		     CAIF_CHTYPE_VIDEO
+ * @u.video.connection_id:   Mandatory Connection ID must be specified.
+ *
+ * @u.rfm		     CAIF_CHTYPE_RFM
+ * @u.rfm.connection_id:     Mandatory Connection ID must be specified.
+ * @u.rfm.volume:	     Mandatory Volume to mount.
+ *
+ * @u.utility:		     CAIF_CHTYPE_UTILITY
+ * @u.utility.fifosize_kb:   Psock: FIFO size in KB
+ * @u.utility.fifosize_bufs: Psock: # signal buffers
+ * @u.utility.name:	     Psock: Name of service
+ * @u.utility.params:	     Psock: Channel Config Parameters
+ * @u.utility.paramlen:	     Psock: Length of Channel Config Parameters
+ *
+ *
+ * It holds configuration parameters for setting up all devined CAIF
+ * Channel types.
+ * The four first fields are mandatory, then Physical Device can be specified
+ * either by name
+ * or by prefered characteristics.
+ * The rest of the configuration fields are hold in a union for each
+ * channel type and are channel type specific.
+ * \b Documentation see STE Doc No: 155 19-CRH 109 913.
+ */
+
+struct caif_channel_config {
+       /* Mandatory: Nickname for this device */
+	char name[16];
+	/* Mandatory: Define the type of caif service */
+	enum caif_channel_type type;
+	/** Mandatory: Mandatory - Value between
+	  * CAIF_PRIO_MIN and CAIF_PRIO_MAX, CAIF_PRIO_LOW, CAIF_PRIO_NORMAL,
+	  *  CAIF_PRIO_HIGH are suggested values. */
+	unsigned priority;
+
+	/** Either: Specify type of physical interface to use. */
+	enum caif_phy_preference phy_pref;
+	/** Or: Specify identity of the physical interface. */
+	char phy_name[16];
+
+	/** Union of Channel Type Specific configuration parameters
+	* 'switched' by attribute type */
+	union {
+		/* CAIF_CHTYPE_DATAGRAM */
+		struct {
+		       /**  Mandatory Connection ID  must be specified. */
+			unsigned connection_id;
+		} dgm;
+		/* CAIF_CHTYPE_VIDEO */
+		struct {
+			/** Datagram:  Mandatory Connection ID Must be
+			 *  specified. */
+			unsigned connection_id;
+		} video;
+		/* CAIF_CHTYPE_RFM */
+		struct {
+			/** RFM: Mandatory Connection ID. */
+			unsigned connection_id;
+			/** RFM: Mandatory Volume to mount. */
+			char volume[20];
+		} rfm;
+		/* CAIF_CHTYPE_UTILITY */
+		struct {
+/** Psock: FIFO size in KB */
+			unsigned fifosize_kb;
+/** Psock: # signal buffers */
+			unsigned fifosize_bufs;
+/** Psock: Name of service */
+			char name[16];
+/** Psock: Channel Config Parameters> */
+			unsigned char params[256];
+/** Psock: Length of Channel Config Parameters */
+			int paramlen;
+		} utility;
+
+
+		/* Raw Data configuration: DO NOT USE,
+		 * applies for testing only */
+
+		struct raw {
+			unsigned channeltype;
+			unsigned char endpoint:2;
+			unsigned char subtype:2;
+			unsigned char serviceconfig[512];
+			unsigned int service_length;
+		} _raw;
+	} u;
+
+};
+
+#endif				/* CAIF_CONFIG_H_ */
diff --git a/include/linux/caif/caif_ioctl.h b/include/linux/caif/caif_ioctl.h
new file mode 100644
index 0000000..421a4b2
--- /dev/null
+++ b/include/linux/caif/caif_ioctl.h
@@ -0,0 +1,113 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+
+#ifndef CAIF_IOCTL_H_
+#define CAIF_IOCTL_H_
+#include <linux/caif/caif_config.h>
+
+
+/*!\page  caif_ioctl.h
+ * This file defines the management interface to CAIF.
+ * It defines how CAIF Channels are configured and become visible in Linux
+ * file system under "/dev/caifconfig".
+ *
+ *\b Example - creating a new AT character device:
+ * \code
+   fd = open("/dev/caifconfig",..);
+   struct caif_channel_create_action at_config = {
+	 .name = "cnhl2",
+	 .config = {
+	    .channel = CAIF_CHTY_AT,
+	    .phy_ref = CAIF_PHY_LOW_LAT,
+	    .priority = CAIF_PRIO_HIGH
+	 }};
+   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
+   close(fd);
+ * \endcode
+ * This will cause a new AT channel to be available in at "/dev/chnl2".
+ * This CAIF channel can then be connected by using \ref open.
+ *
+*/
+
+/*! \addtogroup caif_ioctl
+ *  Additional documentation for group `caif_config.h'
+ *  @{
+ */
+
+
+
+/* Use 'g' as magic number. 'g' is the first free letter in
+ * Documentation/ioctl-number.txt*/
+#define CAIF_IOC_MAGIC 'g'
+#define DEVICE_NAME_LEN 16
+
+/* Specifies the type of device to create NET device or CHAR device*/
+enum caif_dev_type {
+	CAIF_DEV_CHR = 1,
+	CAIF_DEV_NET = 2
+};
+
+
+/** Used for identifying devices, PHY interfaces etc*/
+struct caif_device_name {
+	char name[DEVICE_NAME_LEN];	/*!< Device name */
+	enum caif_dev_type devtype;	/*!< Device type */
+};
+
+
+/**
+ * CAIF ACTION for \ref CAIF_ACT_CHANNEL_CONFIG.
+ * This structure is used to configure a new CAIF Channel and
+ * create the corresponding character device.
+ */
+struct caif_channel_create_action {
+	/** \b in  CAIF Configuration Request */
+	struct caif_channel_config config;
+	/** \b in/out Device name returned from ACTION */
+	struct caif_device_name name;
+	/** \b out Major device id */
+	int major;
+	/** \b out Minor device id */
+	int minor;
+};
+
+/**
+ * union caif_action
+ * This union is used to configure a new CAIF Channel and
+ */
+
+union caif_action {
+	struct caif_device_name delete_channel;
+	struct caif_channel_create_action create_channel;
+};
+
+
+/**
+ * CAIF IOCTL for \ref CAIF_IOC_CHANNEL_CONFIG.
+ * This structure is used to configure a new CAIF Channel and
+ * create the corresponding character device.
+ */
+
+/** Create and Configure a new CAIF device.
+ * Note that the device is not implicitly connected. */
+#define CAIF_IOC_CONFIG_DEVICE		_IOWR(CAIF_IOC_MAGIC, 1,\
+struct caif_channel_create_action)
+
+/** Remove a CAIF device. Requires the device to be previously disconnected. */
+#define CAIF_IOC_REMOVE_DEVICE		_IOWR(CAIF_IOC_MAGIC, 2,\
+		struct caif_device_name)
+#define CAIF__IOC_MAXNR				9
+/*! @} */
+
+#endif				/* CAIF_IOCTL_H_ */
-- 
1.6.0.4

