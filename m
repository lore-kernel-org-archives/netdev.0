From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Wed, 20 Jan 2010 23:55:19 +0100
Message-ID: <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab0ATX4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:21 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CDIIDEGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:02 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:01 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add CAIF types for Socket Address, Socket Options,
and configuration parameters for the GPRS IP network interface.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_config.h |  155 ++++++++++++++++++++++++++++++++++++
 include/linux/caif/caif_socket.h |  161 ++++++++++++++++++++++++++++++++++++++
 include/linux/caif/if_caif.h     |   71 +++++++++++++++++
 3 files changed, 387 insertions(+), 0 deletions(-)

diff --git a/include/linux/caif/caif_config.h b/include/linux/caif/caif_config.h
new file mode 100644
index 0000000..5de8bd2
--- /dev/null
+++ b/include/linux/caif/caif_config.h
@@ -0,0 +1,155 @@
+/*
+ * CAIF Channel Configuration definitions.
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_CONFIG_H_
+#define CAIF_CONFIG_H_
+
+/**
+ * enum caif_phy_preference  -	Types of physical HW interfaces
+ *				towards modem defined in CAIF stack
+ * @CAIF_PHYPREF_UNSPECIFIED:	Default physical interface
+ * @CAIF_PHYPREF_LOW_LAT:	Default physical interface for low-latency
+ *				traffic
+ * @CAIF_PHYPREF_HIGH_BW:	Default physical interface for high-bandwidth
+ *				traffic
+ * @CAIF_PHYPREF_LOOP:		TEST Loopback interface, simulating modem
+ *				responses
+ *
+ * For client convenience, two special types are defined:
+ * CAIF_PHYPREF_LOW_LAT is the preferred low-latency physical link.
+ * Typically used for "control" purposes.
+ * CAIF_PHYPREF_HIGH_BW is the preferred high-bandwidth physical link.
+ * Typically used for "payload" purposes.
+ */
+enum caif_phy_preference {
+	CAIF_PHYPREF_UNSPECIFIED,
+	CAIF_PHYPREF_LOW_LAT,
+	CAIF_PHYPREF_HIGH_BW,
+	CAIF_PHYPREF_LOOP
+};
+
+/*
+ * Define CAIF channel priority.
+ * Used when setting up a channel to specify the
+ * priority level of the channel.
+ */
+#define CAIF_PRIO_MIN	       0x01	/* Min priority for a channel */
+#define CAIF_PRIO_LOW	       0x04	/* low-priority channel. */
+#define CAIF_PRIO_NORMAL       0x0f	/* normal/default priority level. */
+#define CAIF_PRIO_HIGH	       0x14	/* high priority level */
+#define CAIF_PRIO_MAX	       0x1F	/* Max priority for channel */
+
+
+/**
+ * enum caif_channel_type - Types of CAIF channel type defined in CAIF Stack.
+ * @CAIF_CHTY_AT:		Classical AT
+ * @CAIF_CHTY_AT_CTRL:		AT control only
+ * @CAIF_CHTY_AT_PAIRED:	Paired control and data
+ * @CAIF_CHTY_DATAGRAM:		Datagram. Requires: connection_id
+ * @CAIF_CHTY_DATAGRAM_LOOP:	Datagram loopback (testing purposes only)
+ * @CAIF_CHTY_VIDEO:		Video channel
+ * @CAIF_CHTY_DEBUG:		Debug service (Debug server and
+ *					       interactive debug)
+ * @CAIF_CHTY_DEBUG_TRACE:	Debug server only
+ * @CAIF_CHTY_DEBUG_INTERACT:	Debug interactive
+ * @CAIF_CHTY_RFM:		RFM service. Params: connection_id, volume
+ * @CAIF_CHTY_UTILITY:		Utility (Psock) service.
+ *				Params: fifo_kb,fifo_pkt, name, psock_param
+ *
+ * This is used for channel configuration, specifying the type of channel.
+ */
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
+	CAIF_CHTY_UTILITY
+};
+
+/**
+ *struct caif_channel_config - This structure is used for configuring
+ *			     CAIF channels.
+ * @name:		     Mandatory - Nickname for this device
+ * @type:		     Mandatory - Define the type of caif service
+ * @priority:		     Mandatory - Value between	CAIF_PRIO_MIN and
+ *			     CAIF_PRIO_MAX.
+ *			     CAIF_PRIO_LOW, CAIF_PRIO_NORMAL, CAIF_PRIO_HIGH
+ *			     are suggested values.
+ * @phy_pref:		     Either: Specify type of physical interface to use.
+ * @phy_name:		     Or: Specify identity of the physical interface.
+ *
+ * @u:			     Union of channel type-specific configuration
+ *			     parameters
+ *
+ * @u.dgm:		     CAIF_CHTYPE_DATAGRAM
+ * @u.dgm.connection_id:     Mandatory - Connection ID must be specified.
+ *
+ * @u.video:		     CAIF_CHTYPE_VIDEO
+ * @u.video.connection_id:   Mandatory - Connection ID must be specified.
+ *
+ * @u.rfm		     CAIF_CHTYPE_RFM
+ * @u.rfm.connection_id:     Mandatory - Connection ID must be specified.
+ * @u.rfm.volume:	     Mandatory - Volume to mount.
+ *
+ * @u.utility:		     CAIF_CHTYPE_UTILITY
+ * @u.utility.fifosize_kb:   Psock: FIFO size in KB
+ * @u.utility.fifosize_bufs: Psock: Number of signal buffers
+ * @u.utility.name:	     Psock: Name of service
+ * @u.utility.params:	     Psock: Channel config parameters
+ * @u.utility.paramlen:	     Psock: Length of channel config parameters
+ *
+ *
+ * It holds configuration parameters for setting up all defined CAIF
+ * channel types.
+ * The four first fields are mandatory, then physical interface can be specified
+ * either by name or by prefered characteristics.
+ * The rest of the configuration fields are held in a union for each
+ * channel type and are channel type specific.
+ */
+struct caif_channel_config {
+	char name[16];
+	enum caif_channel_type type;
+	unsigned priority;
+	enum caif_phy_preference phy_pref;
+	char phy_name[16];
+
+	/** Union of channel type-specific configuration parameters.
+	 * 'switched' by attribute type.
+	 */
+	union {
+		/* CAIF_CHTYPE_DATAGRAM */
+		struct {
+			unsigned connection_id;
+		} dgm;
+		/* CAIF_CHTYPE_VIDEO */
+		struct {
+			unsigned connection_id;
+		} video;
+		/* CAIF_CHTYPE_RFM */
+		struct {
+			unsigned connection_id;
+			char volume[20];
+		} rfm;
+		/* CAIF_CHTYPE_UTILITY */
+		struct {
+			unsigned fifosize_kb;
+			unsigned fifosize_bufs;
+			char name[16];
+			unsigned char params[256];
+			int paramlen;
+		} utility;
+
+	} u;
+};
+
+#endif				/* CAIF_CONFIG_H_ */
diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
new file mode 100644
index 0000000..44774e8
--- /dev/null
+++ b/include/linux/caif/caif_socket.h
@@ -0,0 +1,161 @@
+/* linux/caif_socket.h
+ * CAIF Definitions for CAIF socket and network layer
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	 Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef _LINUX_CAIF_SOCKET_H
+#define _LINUX_CAIF_SOCKET_H
+
+#ifdef __KERNEL__
+#include <linux/types.h>
+#include <linux/socket.h>
+#else
+#include <sys/types.h>
+#include <sys/socket.h>
+#endif
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+/**
+ * enum caif_link_selector -   Physical Link Selection.
+ * @CAIF_LINK_HIGH_BANDW:	Default physical interface for high-bandwidth
+ *				traffic.
+ * @CAIF_LINK_LOW_LATENCY:	Default physical interface for low-latency
+ *				traffic.
+ */
+enum caif_link_selector {
+	CAIF_LINK_HIGH_BANDW,
+	CAIF_LINK_LOW_LATENCY
+};
+
+/**
+ * enum caif_protocol_type  -	Types of CAIF protocols in the CAIF Stack.
+ * @CAIFPROTO_AT:		Classic AT channel.
+ * @CAIFPROTO_DATAGRAM:		Datagram channel.
+ * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel, used for testing.
+ * @CAIFPROTO_UTIL:		Utility (Psock) channel.
+ * @CAIFPROTO_RFM:		Remote File Manager
+ */
+enum caif_protocol_type {
+	CAIFPROTO_AT,
+	CAIFPROTO_DATAGRAM,
+	CAIFPROTO_DATAGRAM_LOOP,
+	CAIFPROTO_UTIL,
+	CAIFPROTO_RFM,
+	_CAIFPROTO_MAX
+};
+#define	CAIFPROTO_MAX _CAIFPROTO_MAX
+
+/**
+ * enum caif_at_type - AT Service Endpoint
+ * @CAIF_ATTYPE_PLAIN:	     Connects to a plain vanilla AT channel.
+ */
+enum caif_at_type {
+	CAIF_ATTYPE_PLAIN
+};
+
+/**
+ * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
+ * @u:			     Union of address data 'switched' by familty.
+ * @at:			     Applies when family = CAIFPROTO_AT.
+ * @at.type:		     Type of AT link to set up (enum caif_at_type).
+ * @util:		     Applies when family = CAIFPROTO_UTIL
+ * @util.service:	     Service name.
+ * @dgm:		     Applies when family = CAIFPROTO_DATAGRAM
+ * @dgm.connection_id:	     Datagram connection id.
+ * @dgm.nsapi:		     NSAPI of the PDP-Context.
+ * @rfm:		     Applies when family = CAIFPROTO_RFM
+ * @rfm.connection_id:       Connection ID for RFM.
+ * @rfm.volume:	     	     Volume to mount.
+ */
+struct sockaddr_caif {
+	sa_family_t  family;
+	union {
+		struct {
+			u_int8_t  type;		/* type: enum caif_at_type */
+		} at;				/* CAIFPROTO_AT */
+		struct {
+			char	  service[16];
+		} util;				/* CAIFPROTO_UTIL */
+		union {
+			u_int32_t connection_id;
+			u_int8_t  nsapi;
+		} dgm;				/* CAIFPROTO_DATAGRAM(_LOOP)*/
+		struct {
+			u_int32_t connection_id;
+			char	  volume[16];
+		} rfm;				/* CAIFPROTO_RFM */
+	} u;
+};
+
+/**
+ * struct caif_channel_opt - CAIF channel connect options.
+ * @priority:		Priority of the channel (between 0 and 0x1f)
+ * @link_selector:	Selector for the physical link.
+ *			(see enum caif_phy_preference in caif_config.h)
+ * @link_name:		Physical link to use. This is the instance name of the
+ *			CAIF Physical Driver.
+ */
+struct caif_channel_opt {
+	u_int16_t  priority;
+	u_int16_t  link_selector;
+	char	   link_name[16];
+};
+
+/**
+ * struct caif_param - CAIF parameters.
+ * @size:	Length of data
+ * @data:	Binary Data Blob
+ */
+struct caif_param {
+	u_int16_t  size;
+	u_int8_t   data[256];
+};
+
+
+/** enum caif_socket_opts - CAIF option values for getsockopt and setsockopt
+ * @CAIFSO_CHANNEL:		Used to set the connect options on a CAIF
+ *				socket. (struct caif_config_opt). This can only
+ *				be set before connecting.
+ * @CAIFSO_REQ_PARAM:		Used to set the request parameters for a
+ *				utility channel. (struct caif_param). This
+ *				can only be set before connecting.
+ *
+ * @CAIFSO_RSP_PARAM:		Gets the request parameters for a utility
+ *				channel. (struct caif_param). This can only be
+ *				fetched after connecting the socket.
+ *
+ * @CAIFSO_UTIL_FLOW:		Sets the utility channels flow options.
+ *				This can only be set before connecting.
+ *				(struct caif_util_modem_flow_opt)
+ *
+ * @CAIFSO_CONN_ID:		Gets the channel id on a CAIF Channel.
+ *				This can only be done after connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_NEXT_PAKCET_LEN:	Gets the size of next received packet.
+ *				Value is 0 if no packet is available.
+ *				This can only be done after connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_MAX_PAKCET_LEN:	Gets the maximum packet size for this
+ *				connection. ( u_int32_t)
+ */
+enum caif_socket_opts {
+	CAIFSO_CHANNEL_CONFIG	= 127,
+	CAIFSO_REQ_PARAM	= 128,
+	CAIFSO_RSP_PARAM	= 129,
+	CAIFSO_UTIL_FLOW	= 130,
+	CAIFSO_CONN_ID		= 131,
+	CAIFSO_NEXT_PACKET_LEN	= 132,
+	CAIFSO_MAX_PACKET_LEN	= 133,
+};
+
+#ifdef __cplusplus
+}				/* extern "C" */
+#endif
+#endif /* _LINUX_CAIF_SOCKET_H */
diff --git a/include/linux/caif/if_caif.h b/include/linux/caif/if_caif.h
new file mode 100644
index 0000000..e1991b1
--- /dev/null
+++ b/include/linux/caif/if_caif.h
@@ -0,0 +1,71 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland/ sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef IF_CAIF_H_
+#define IF_CAIF_H_
+#include <linux/sockios.h>
+#include <linux/types.h>
+#include <linux/socket.h>
+
+/**
+ * enum sioc_caif -	SOCKIO for creating new CAIF Net Devices.
+ * @SIOCCAIFNETNEW:	Used to create a new instance of the CAIF IP Interface.
+ *			struct ifreq containing struct ifcaif_param are used
+ *			as parameters. ifr_name must be filled in.
+ * @SIOCCAIFNETCHANGE:	As above, but changes a disconnected CAIF IP Inteface.
+ * @SIOCCAIFNETREMOVE:	Removes a CAIF IP Interface.
+ *
+ * CAIF IP Interface can be created, changed and deleted,
+ * by this enum. In addition standard Socket IO Controls (SIGIOC*)
+ * can be used to manage standard IP Interface parameters.
+ * The struct ifreq are used to carry parameters.
+ */
+enum sioc_caif {
+	SIOCCAIFNETNEW = SIOCPROTOPRIVATE,
+	SIOCCAIFNETCHANGE,
+	SIOCCAIFNETREMOVE
+};
+
+
+/**
+ * struct ifcaif_param - Parameters for creating CAIF Network Interface.
+ *
+ * When using SIOCCAIFNETNEW to create a CAIF IP interface, this structure
+ * is used for configuration data.
+ * The attribute ifr_ifru.ifru_data in struct struct ifreq must be set
+ * point at an instance of struct ifcaif_param.
+ *
+ * @ipv4_connid:  Connection ID for IPv4 PDP Context.
+ * @ipv6_connid:  Connection ID for IPv6 PDP Context.
+ * @loop:	  If different from zero, device is doing loopback
+ */
+struct ifcaif_param {
+	__u32			ipv4_connid;
+	__u32			ipv6_connid;
+	__u8			loop;
+};
+
+/**
+ * enum ifla_caif
+ * When using RT Netlink to create, destroy or configure a CAIF IP interface,
+ * enum ifla_caif is used to specify the configuration attributes.
+ *
+ * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing loopback
+ *			    The type of attribute is NLA_U8.
+ */
+enum ifla_caif {
+	IFLA_CAIF_IPV4_CONNID,
+	IFLA_CAIF_IPV6_CONNID,
+	IFLA_CAIF_LOOPBACK,
+	__IFLA_CAIF_MAX
+};
+#define	IFLA_CAIF_MAX (__IFLA_CAIF_MAX-1)
+
+#endif /*IF_CAIF_H_*/
-- 
1.6.3.3

