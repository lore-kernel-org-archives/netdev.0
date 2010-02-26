From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v4 02/12] net-caif: add CAIF socket and configuration headers
Date: Fri, 26 Feb 2010 23:13:27 +0100
Message-ID: <1267222417-2764-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1267222417-2764-1-git-send-email-sjur.brandeland@stericsson.com>
 <1267222417-2764-2-git-send-email-sjur.brandeland@stericsson.com>
Cc: daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gktv.no ([80.239.85.213]:58309 "EHLO mail.gktv.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966371Ab0BZWWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 17:22:14 -0500
In-Reply-To: <1267222417-2764-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add CAIF types for Socket Address, Socket Options,
and configuration parameters for the GPRS IP network interface.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/linux/caif/caif_socket.h |  188 ++++++++++++++++++++++++++++++++++++++
 include/linux/caif/if_caif.h     |   34 +++++++
 2 files changed, 222 insertions(+), 0 deletions(-)

diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_socket.h
new file mode 100644
index 0000000..f0aea0a
--- /dev/null
+++ b/include/linux/caif/caif_socket.h
@@ -0,0 +1,188 @@
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
+
+/**
+ * enum caif_link_selector -    Physical Link Selection.
+ * @CAIF_LINK_HIGH_BANDW:	Physical interface for high-bandwidth
+ *				traffic.
+ * @CAIF_LINK_LOW_LATENCY:	Physical interface for low-latency
+ *				traffic.
+ *
+ * CAIF Link Layers can register their link properties.
+ * This enum is used for choosing between CAIF Link Layers when
+ * setting up CAIF Channels when multiple CAIF Link Layers exists.
+ */
+enum caif_link_selector {
+	CAIF_LINK_HIGH_BANDW,
+	CAIF_LINK_LOW_LATENCY
+};
+
+/**
+ * enum caif_channel_priority - CAIF channel priorities.
+ *
+ * @CAIF_PRIO_MIN:	Min priority for a channel.
+ * @CAIF_PRIO_LOW:	Low-priority channel.
+ * @CAIF_PRIO_NORMAL:	Normal/default priority level.
+ * @CAIF_PRIO_HIGH:	High priority level
+ * @CAIF_PRIO_MAX:	Max priority for channel
+ *
+ * Priority can be set on CAIF Channels in order to
+ * prioritize between traffic on different CAIF Channels.
+ * These priority levels are recommended, but the priority value
+ * is not restricted to the values defined in this enum, any value
+ * between CAIF_PRIO_MIN and CAIF_PRIO_MAX could be used.
+ */
+enum caif_channel_priority {
+	CAIF_PRIO_MIN	 = 0x01,
+	CAIF_PRIO_LOW	 = 0x04,
+	CAIF_PRIO_NORMAL = 0x0f,
+	CAIF_PRIO_HIGH	 = 0x14,
+	CAIF_PRIO_MAX	 = 0x1F
+};
+
+/**
+ * enum caif_protocol_type  -	CAIF Channel type.
+ * @CAIFPROTO_AT:		Classic AT channel.
+ * @CAIFPROTO_DATAGRAM:		Datagram channel.
+ * @CAIFPROTO_DATAGRAM_LOOP:	Datagram loopback channel, used for testing.
+ * @CAIFPROTO_UTIL:		Utility (Psock) channel.
+ * @CAIFPROTO_RFM:		Remote File Manager
+ *
+ * This enum defines the CAIF Channel type to be used. This defines
+ * the service to connect to on the modem.
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
+	CAIF_ATTYPE_PLAIN = 2
+};
+
+/**
+ * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
+ * @u:			     Union of address data 'switched' by family.
+ * :
+ * @u.at:                    Applies when family = CAIFPROTO_AT.
+ *
+ * @u.at.type:               Type of AT link to set up (enum caif_at_type).
+ *
+ * @u.util:                  Applies when family = CAIFPROTO_UTIL
+ *
+ * @u.util.service:          Utility service name.
+ *
+ * @u.dgm:                   Applies when family = CAIFPROTO_DATAGRAM
+ *
+ * @u.dgm.connection_id:     Datagram connection id.
+ *
+ * @u.dgm.nsapi:             NSAPI of the PDP-Context.
+ *
+ * @u.rfm:                   Applies when family = CAIFPROTO_RFM
+ *
+ * @u.rfm.connection_id:     Connection ID for RFM.
+ *
+ * @u.rfm.volume:            Volume to mount.
+ *
+ * Description:
+ * This structure holds the connect parameters used for setting up a
+ * CAIF Channel. It defines the service to connect to on the modem.
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
+ * struct caif_param - CAIF parameters.
+ * @size:	Length of data
+ * @data:	Binary Data Blob
+ */
+struct caif_param {
+	u_int16_t  size;
+	u_int8_t   data[256];
+};
+
+/**
+ * enum caif_socket_opts - CAIF option values for getsockopt and setsockopt.
+ *
+ * @CAIFSO_LINK_SELECT:		Selector used if multiple CAIF Link layers are
+ *				available. Either a high bandwidth
+ *				link can be selected (CAIF_LINK_HIGH_BANDW) or
+ *				or a low latency link (CAIF_LINK_LOW_LATENCY).
+ *                              This option is of type u_int32_t.
+ *				Alternatively SO_BINDTODEVICE can be used.
+ *
+ * @CAIFSO_REQ_PARAM:		Used to set the request parameters for a
+ *				utility channel. (struct caif_param). This
+ *				option must be set before connecting.
+ *
+ * @CAIFSO_RSP_PARAM:		Gets the request parameters for a utility
+ *				channel. (struct caif_param). This option
+ *				is valid after a successful connect.
+ *
+ * @CAIFSO_CHANNEL_ID:		Gets the channel id on a CAIF Channel.
+ *				This option is valid after a successful connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_NEXT_PAKCET_LEN:	Gets the size of next received packet.
+ *				Value is 0 if no packet is available.
+ *				This option is valid after a successful connect.
+ *				( u_int32_t)
+ *
+ * @CAIFSO_MAX_PAKCET_LEN:	Gets the maximum packet size for this
+ *				connection. ( u_int32_t)
+ *
+ * This enum defines the CAIF Socket options to be used on a socket
+ *
+ */
+enum caif_socket_opts {
+	CAIFSO_LINK_SELECT	= 127,
+	CAIFSO_REQ_PARAM	= 128,
+	CAIFSO_RSP_PARAM	= 129,
+	CAIFSO_CHANNEL_ID	= 130,
+	CAIFSO_NEXT_PACKET_LEN	= 131,
+	CAIFSO_MAX_PACKET_LEN	= 132,
+};
+
+#endif /* _LINUX_CAIF_SOCKET_H */
diff --git a/include/linux/caif/if_caif.h b/include/linux/caif/if_caif.h
new file mode 100644
index 0000000..5e7eed4
--- /dev/null
+++ b/include/linux/caif/if_caif.h
@@ -0,0 +1,34 @@
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
+ * enum ifla_caif - CAIF NetlinkRT parameters.
+ * @IFLA_CAIF_IPV4_CONNID:  Connection ID for IPv4 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_IPV6_CONNID:  Connection ID for IPv6 PDP Context.
+ *			    The type of attribute is NLA_U32.
+ * @IFLA_CAIF_LOOPBACK:	    If different from zero, device is doing loopback
+ *			    The type of attribute is NLA_U8.
+ *
+ * When using RT Netlink to create, destroy or configure a CAIF IP interface,
+ * enum ifla_caif is used to specify the configuration attributes.
+ */
+enum ifla_caif {
+	__IFLA_CAIF_UNSPEC,
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

