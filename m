From: sjur.brandeland@stericsson.com
Subject: [PATCH 3/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:16 +0200
Message-ID: <1253727076-10293-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55448 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbZIWSbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:23 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003P7Q07F560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:19 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF00KKXQ063BA1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:19 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>


Signed-off-by: sjur.brandeland@stericsson.com
---
 include/net/caif/caif_actions.h     |   81 +++++++++
 include/net/caif/caif_chr.h         |   52 ++++++
 include/net/caif/caif_config_util.h |   27 +++
 include/net/caif/caif_kernel.h      |  324 +++++++++++++++++++++++++++++++++++
 include/net/caif/caif_log.h         |   83 +++++++++
 5 files changed, 567 insertions(+), 0 deletions(-)
 create mode 100644 include/net/caif/caif_actions.h
 create mode 100644 include/net/caif/caif_chr.h
 create mode 100644 include/net/caif/caif_config_util.h
 create mode 100644 include/net/caif/caif_kernel.h
 create mode 100644 include/net/caif/caif_log.h

diff --git a/include/net/caif/caif_actions.h b/include/net/caif/caif_actions.h
new file mode 100644
index 0000000..fe474f7
--- /dev/null
+++ b/include/net/caif/caif_actions.h
@@ -0,0 +1,81 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+#ifndef CAIF_ACTION_H_
+#define CAIF_ACTION_H_
+#include "caif_config.h"
+#include "caif_ioctl.h"
+
+#define DEVICE_NAME_LEN 16
+
+/**
+ * Types of Physical HW Interfaces towards modem defined in CAIF Stack,
+ * used when CAIF enumerates Interfaces and for Channel Configuration.
+ *
+ * For Client convenience to special types are defined:
+ *  - \ref CAIF_PHY_LOW_LAT is the preferred low latency physical link.
+ *         Typically used for "control" purposes.
+ *  - \ref CAIF_PHY_HIGH_BW is the preferred high bandwidth physical link.
+ *         Typically used for "payload" purposes.
+ *  - \ref CAIF_PHY_UNCPECIFIED CAIF Stack implementation will assign link
+ *         for you.
+ *
+ */
+enum caif_phy_type {
+	CAIF_PHY_UNSPECIFIED = 0x00,	/*!< Default Physical Interface */
+	CAIF_PHY_SERIAL = 0x10,	/*!< Serial Physical Interface */
+	CAIF_PHY_SPI = 0x20,	/*!< SPI Physical Interface */
+	CAIF_PHY_MSL = 0x30,	/*!< MSL Physical Interface */
+	CAIF_PHY_SHM = 0x40,	/*!< Shared Memory Interface */
+	CAIF_PHY_LOOP = 0x70,	/*!< Loop-back Interface Simulating ACC side
+				   responses */
+	CAIF_PHY_RAW_LOOP = 0x80,	/*!< Raw loop-back interface */
+};
+#define CAIF_PHY_MASK  0xf0
+
+
+
+
+
+
+union caif_action {
+	struct caif_device_name delete_channel;
+	struct caif_channel_create_action create_channel;
+};
+
+
+/** Query the names of the Enumerated CAIF Physical Interfaces. */
+#define CAIF_ACT_LIST_PHYIFS 	         1	/*struct caif_device_list_action) */
+
+/** Get the physical interface information, given the name. */
+#define CAIF_ACT_GET_PHYIF_INFO 	 2	/*struct caif_phyif_info_action) */
+
+/** Enumerate a physical interface. */
+#define CAIF_ACT_ACTIVATE_PHYIF 		  3	/*struct caif_phy_activate) */
+
+/** Removes (De-Enumerates) a physical interface. */
+#define CAIF_ACT_DEACT_DEVICE 		 4	/*struct caif_device_name) */
+
+/** Get the device names of configured devices */
+#define CAIF_ACT_LIST_DEVICE_NAMES 	  5	/*struct caif_device_list_action) */
+
+/** Get configuration and status information for a specified CAIF device */
+#define CAIF_ACT_GET_DEVICE_INFO  	 6	/*struct caif_device_info_action) */
+
+/** Create and Configure a new CAIF device. Note that the device is not
+ * implicitly connected. */
+
+#define CAIF_ACT_CREATE_DEVICE 		 7 /*struct caif_channel_create_action*/
+
+/** Remove a CAIF device. Requires the device to be previously disconnected. */
+#define CAIF_ACT_DELETE_DEVICE           8	/*struct caif_device_name) */
+
+
+
+#endif
diff --git a/include/net/caif/caif_chr.h b/include/net/caif/caif_chr.h
new file mode 100644
index 0000000..f257d74
--- /dev/null
+++ b/include/net/caif/caif_chr.h
@@ -0,0 +1,52 @@
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
+#ifndef CAIF_CHR_H_
+#define CAIF_CHR_H_
+
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfspil.h"
+#include "caif_config.h"
+#include "caif_actions.h"
+struct caif_service_config;
+
+typedef enum _cf_chr_dev_type_t {
+	CFDEVTYPE_CHR,
+	CFDEVTYPE_TTY,
+	CFDEVTYPE_NET
+} cf_chr_dev_type_t;
+
+extern int serial_use_stx;
+
+int caifdev_phy_reg(layer_t *phyif, cfcnfg_phy_mgmt_t *mgmt);
+int caifdev_phy_instanciate(cfcnfg_phy_config_t *phy_config);
+int caifdev_phy_register(layer_t *phyif, cfcnfg_phy_type_t phy_type,
+			 cfcnfg_phy_preference_t phy_pref);
+int caifdev_phy_unregister(layer_t *phyif);
+int caifdev_phy_loop_register(layer_t *phyif, cfcnfg_phy_type_t phy_type);
+int caifdev_phy_spi_xmitlen(cfspil_t *layr);
+cfpkt_t *caifdev_phy_spi_getxmitpkt(cfspil_t *layr);
+int caifdev_adapt_register(struct caif_channel_config *config,
+			   layer_t *adap_layer);
+int caifdev_adapt_unregister(layer_t *adap_layer);
+
+int caif_register_chrdev(int (*chrdev_mgmt)
+			  (int action, union caif_action *param));
+void caif_unregister_chrdev(void);
+
+int caif_register_netdev(int (*netdev_mgmt)
+		     (int action, union caif_action *param));
+void caif_unregister_netdev(void);
+
+#endif				/* CAIF_CHR_H_ */
diff --git a/include/net/caif/caif_config_util.h b/include/net/caif/caif_config_util.h
new file mode 100644
index 0000000..3506993
--- /dev/null
+++ b/include/net/caif/caif_config_util.h
@@ -0,0 +1,27 @@
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
+#ifndef CAIF_CONFIG_UTIL_H_
+#define CAIF_CONFIG_UTIL_H_
+
+#include "caif_config.h"
+#include "caif_ioctl.h"
+#include "cfcnfg.h"
+#include "cfctrl.h"
+#include "caif_actions.h"
+
+int channel_config_2_link_param(cfcnfg_t *cnfg,
+				struct caif_channel_config *s,
+				cfctrl_link_param_t *l);
+
+#endif
diff --git a/include/net/caif/caif_kernel.h b/include/net/caif/caif_kernel.h
new file mode 100644
index 0000000..ff1164a
--- /dev/null
+++ b/include/net/caif/caif_kernel.h
@@ -0,0 +1,324 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      CAIF Kernel Internal interface for configuring and accessing
+ *      CAIF Channels.
+ *
+ *      Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ */
+
+#ifndef CAIF_KERNEL_H_
+#define CAIF_KERNEL_H_
+#include "caif_config.h"
+struct sk_buff;
+
+/*!\page  caif_kernel.h
+ * This is the specification of the CAIF Kernel internal interface to
+ * CAIF Channels.
+ * This interface follows the pattern used in Linux Device Drivers with a
+ *  struct \ref caif_device
+ * holding control data handling each device instance.
+ *
+ * The functional interface consist of a few basic functions:
+ *  - \ref caif_add_device             Configures and Connect the CAIF
+ *               Channel to the remote end. Configuration is described in
+ *               \ref caif_channel_config.
+ *  - \ref caif_remove_device          Disconnect and remove the Channel.
+ *  - \ref caif_transmit               Sends a CAIF message on the link.
+ *  - \ref caif_device.receive_cb      Receive Callback function for
+ *                receiving packets.
+ *  - \ref caif_device.control_cb      Control information from the CAIF stack.
+ *  - \ref caif_flow_control           Send Flow Control mesasge to remote end.
+ *
+ *
+ * Details:
+ * \see { caif_kernel }
+ *
+ * \code
+ *
+#include "caif_kernel.h"
+
+
+static void my_receive(struct caif_device *dev, struct sk_buff *skb)
+{
+...
+}
+
+static void my_control(struct caif_device *dev, enum caif_control ctrl)
+{
+....
+}
+
+int kernel_caif_usage_exampe()
+{
+struct sk_buff *skb;
+char *message = "hello";
+
+
+// Connect the Channel
+struct caif_device caif_dev = {
+.caif_config = {
+.name = "MYDEV",
+.priority = CAIF_PRIO_NORMAL,
+.type = CAIF_CHTY_UTILITY,
+.phy_pref = CAIF_PHYPREF_LOW_LAT,
+.u.utility.name = "CAIF_PSOCK_TEST",
+.u.utility.params = {0x01},
+.u.utility.paramlen = 1,
+},
+
+.receive_cb = my_receive,
+.control_cb = my_control,
+
+};
+ret = caif_add_device(&caif_dev);
+if (ret)
+goto error;
+
+// Send a packet
+skb = caif_create_skb(message, strlen(message));
+ret = caif_transmit(&caif_dev, skb);
+if (ret)
+goto error;
+
+
+// Remove device
+ret = caif_remove_device(&caif_dev);
+if (ret)
+goto error;
+
+}
+
+* \endcode
+*
+* \section Linux Socket Buffer (SKB)
+    *          When sending out packets on a connection (\ref caif_transmit)
+    *          the CAIF stack will add CAIF protocol headers.
+    *          This requires space in the SKB.
+    *          Caif has defined \ref CAIF_SKB_HEAD_RESERVE for minimum
+    *          required reserved head-space in the packet and
+    *          \ref CAIF_SKB_TAIL_RESERVE for minimum reserved tail-space.
+    *
+    *          \b NOTE The Linux kernel SKB operations panics if not
+    *                  enough space is available!
+    *
+    */
+
+    /*! \addtogroup caif_kernel
+     *  @{
+     */
+
+struct caif_device;
+
+
+    /** Minimum required CAIF Socket Buffer head-space */
+#define CAIF_SKB_HEAD_RESERVE 32
+
+    /** Minimum required CAIF Socket Buffer tail-space */
+#define CAIF_SKB_TAIL_RESERVE 32
+
+    /** CAIF Control information (used in \ref caif_device.control_cb)
+     *   used for receiving control information from Modem. */
+enum caif_control {
+	/** Modem has sent Flow-ON, Clients can start transmitting
+	 *  data using \ref caif_transmit. */
+	CAIF_CONTROL_FLOW_ON = 0,
+	/** Modem has sent Flow-OFF, Clients must stop transmitting
+	 * data using \ref caif_transmit. */
+	CAIF_CONTROL_FLOW_OFF = 1,
+
+	/** Channel Creation is complete. This is an acknowledge to
+	 *  (\ref caif_add_device) from Modem.
+	 *  and the Channel is ready for transmit (Flow-state is ON). */
+	CAIF_CONTROL_DEV_INIT = 3,
+
+	/** Spontaneous close request from Modem, only applicable
+	 *   for Utility Link. The Client should respond by calling
+	 *   \ref caif_remove_device */
+	CAIF_CONTROL_REMOTE_SHUTDOWN = 4,
+
+	/** Channel disconnect is complete. This is an acknowledge to
+	 *  (\ref caif_remove_device) from Modem.
+	 *  \ref caif_transmit or \ref caif_flow_control must not be
+	 *  called after this. */
+	CAIF_CONTROL_DEV_DEINIT = 5,
+
+	/** Channel Creation has failed. This is an negative acknowledge
+	 *  to (\ref caif_add_device) from Modem. */
+	CAIF_CONTROL_DEV_INIT_FAILED = 6
+};
+
+
+/** Flow Control information (used in \ref caif_device.control_cb) used
+ *  for controlling outgoing flow */
+enum caif_flowctrl {
+	/** Flow Control is ON, transmit function can start sending data */
+	CAIF_FLOWCTRL_ON = 0,
+	/** Flow Control is OFF, transmit function should stop sending data */
+	CAIF_FLOWCTRL_OFF = 1,
+};
+
+/** Transmits CAIF Packets on Channel.
+ * This function is non-blocking and safe to use in tasklet context.
+ * The CAIF Stack takes ownership of the Socket Buffer (SKB) after calling
+ * \ref caif_transmit.
+ * This means that the user cannot access the SKB afterwards, this applies
+ * even in error situations.
+ *
+ * @return 0 on success, < 0 upon error.
+ *
+ * @param[in] skb         Socket Buffer holding data to be written.
+ * @param[in] dev         Structure used when creating the channel
+ *
+ *
+ * Error codes:
+ *  - \b ENOTCONN,   The Channel is not connected.
+ *  - \b EPROTO,     Protocol error (or skb is faulty)
+ *  - \b EIO         IO Error (unspecified error)
+ */
+int caif_transmit(struct caif_device *dev, struct sk_buff *skb);
+
+
+/** Function for sending flow ON / OFF to remote end.
+ * This function is non-blocking and safe to use in tasklet context.
+ *
+ * @param[in] dev        Reference to device data.
+ * @param[in] flow       Flow Control information.
+
+ * @return 0 on success, < 0 upon error.
+ * Error codes:
+ *  - \b ENOTCONN,   The Channel is not connected.
+ *  - \b EPROTO,     Protocol error.
+ *  - \b EIO         IO Error (unspecified error).
+ */
+int caif_flow_control(struct caif_device *dev, enum caif_flowctrl flow);
+
+
+
+/** Handle for Kernel Internal CAIF Channels.
+ * All fields in this structure must be filled in by Client before calling
+ * \ref caif_add_device (except _caif_handle).
+ */
+struct caif_device {
+
+    /** Channel Configuration Parameter. Contains information about type
+     *	and configuration of the channel.
+     *  This must be set before calling \ref caif_add_device. */
+	struct caif_channel_config caif_config;
+
+
+    /** Callback Function for receiving CAIF Packets from Channel.
+     * This callback is called from softirq context (tasklet).
+     * The receiver <b> must </b> free the skb.
+     * <b> DO NOT BLOCK IN THIS FUNCTION! </b>
+     *
+     * If client has to do blocking operations
+     * it must start it's own work queue (or kernel thread).
+     *
+     * @param[in] dev        Reference to device data.
+     * @param[in] skb       Socket Buffer with received data.
+     */
+	void (*receive_cb) (struct caif_device *dev, struct sk_buff *skb);
+
+
+    /** Callback Function for notifying flow control from remote end see
+     *  \ref caif_control.
+     * This callback is called from from softirq context (tasklet).
+     *
+     * <b> DO NOT BLOCK IN THIS FUNCTION! </b>
+     *
+     * Client must not call \ref caif_transmit from this function.
+     *
+     * If client has queued packets to send
+     * it must start its own thread to do \ref caif_transmit from.
+     *
+     * @param[in] dev        Reference to device data.
+     * @param[in] ctrl       CAIF Control info \ref caif_control.
+     *                       e.g. Flow control
+     *                       \ref CAIF_CONTROL_FLOW_ON or
+     *                       \ref CAIF_CONTROL_FLOW_OFF
+     *
+     */
+	void (*control_cb) (struct caif_device *dev, enum caif_control ctrl);
+
+    /** This is a CAIF private attribute, holding CAIF internal reference
+     * to the CAIF stack. Do not update this field */
+
+	void *_caif_handle;
+
+    /** This field may be filled in by Client for their own usage. */
+	void *user_data;
+};
+
+
+
+/** Add (Connects) a CAIF Channel.
+ * This function is non-blocking. The channel connect is reported in
+ * \ref caif_device.control_cb.
+ * The channel is not open until \ref caif_device.control_cb is called with
+ * \ref CAIF_CONTROL_DEV_INIT.
+ * If setting up the channel fails \ref caif_device.control_cb is called with
+ * \ref CAIF_CONTROL_DEV_INIT_FAILED.
+ *
+ * \ref caif_transmit, \ref caif_flow_control or \ref caif_remove_device must
+ * not be called before receiveing CAIF_CONTROL_DEV_INIT.
+ * @return 0 on success, < 0 on failure.
+ *
+ * Error codes:
+ * - \b -EINVAL    Invalid Arguments
+ * - \b -ENODEV    No PHY Device exists.
+ * - \b -EIO       IO Error (unspecified error)
+ *
+ */
+int caif_add_device(struct caif_device *dev);
+
+
+
+/** Disconnect a CAIF Channel
+ * This function is non-blocking.
+ * The channel is not disconnected until \ref caif_device : control_cb is
+ * called with \ref CAIF_CONTROL_DEV_DEINIT.
+ * \ref caif_transmit or \ref caif_flow_control \b must not be called after
+ * receiving \ref CAIF_CONTROL_DEV_DEINIT.
+ * The Client is responsible for freeing the \ref caif_device structure after
+ * receiving  \ref CAIF_CONTROL_DEV_DEINIT (if applicable).
+ * @return 0 on success.
+ *
+ * - \b EIO       IO Error (unspecified error)
+ *
+ */
+int caif_remove_device(struct caif_device *caif_dev);
+
+
+
+/** Convenience function for allocating a socket buffer for usage with CAIF
+ * and copy user data into the socket buffer.
+ * @param[in] data User data to send with CAIF.
+ * @param[in] data_length of data to send.
+ * @return socket buffer .
+ *
+ */
+struct sk_buff *caif_create_skb(unsigned char *data, unsigned int data_length);
+
+
+/** Convenience function for extracting data from a socket buffer (SKB) and
+ *  then destroy it.
+ *  Copies data from the SKB frees the SKB.
+ * @param[in] skb SKB to extract data from. SKB will be freed after extracting
+ *            data.
+ *
+ * @param[in] data User data buffer to extract packet data into.
+ * @param[in] max_length User data buffer length,
+ * @return number of bytes extracted; < 0 upon error.
+ *
+ */
+int caif_extract_and_destroy_skb(struct sk_buff *skb, unsigned char *data,
+				 unsigned int max_length);
+
+
+
+/*! @} */
+
+#endif				/* CAIF_KERNEL_H_ */
diff --git a/include/net/caif/caif_log.h b/include/net/caif/caif_log.h
new file mode 100644
index 0000000..cbcea05
--- /dev/null
+++ b/include/net/caif/caif_log.h
@@ -0,0 +1,83 @@
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
+#ifndef CAIF_LOG_H_
+#define CAIF_LOG_H_
+
+extern int caif_dbg_level;
+
+#define CAIFLOG_ON 1
+
+#define CAIFLOG_MIN_LEVEL     1
+#define CAIFLOG_LEVEL_ERROR   1
+#define CAIFLOG_LEVEL_WARNING 2
+#define CAIFLOG_LEVEL_TRACE   3
+#define CAIFLOG_LEVEL_TRACE2  4
+#define CAIFLOG_LEVEL_TRACE3  5
+#define CAIFLOG_LEVEL_FUNC    6
+#define CAIFLOG_MAX_LEVEL     6
+
+/** Fatal error condition, halt the kernel */
+#define CAIFLOG_FATAL(format, args...) do if ( \
+	caif_dbg_level > CAIFLOG_LEVEL_ERROR)  \
+	printk(KERN_ERR "<%s:%d, FATAL> " format, __func__, __LINE__ , \
+	## args);\
+  while (0)
+
+/** CAIF Error Logging. */
+#define CAIFLOG_ERROR(format, args...)	do if (\
+caif_dbg_level > CAIFLOG_LEVEL_ERROR)  \
+printk(KERN_ERR "<%s:%d, ERROR> " format, __func__, __LINE__ , ## args);\
+  while (0)
+
+/** CAIF Warning Logging. */
+#define CAIFLOG_WARN(format, args...)	do if (\
+caif_dbg_level > CAIFLOG_LEVEL_WARNING)	 \
+printk(KERN_WARNING "<%s:%d, WARN> "  format, __func__, __LINE__ , ## args);\
+  while (0)
+
+/** CAIF Trace Control Logging. Level 1 control trace (Channel setup etc) */
+#define CAIFLOG_TRACE(format, args...)	do if (\
+caif_dbg_level > CAIFLOG_LEVEL_TRACE)  \
+printk(KERN_WARNING "<%s:%d, TRACE> " format, __func__, __LINE__ , ## args); \
+ while (0)
+
+/** CAIF Trace Payload Logging. Level payload trace */
+#define CAIFLOG_TRACE2(format, args...) do if ( \
+caif_dbg_level > CAIFLOG_LEVEL_TRACE2)	\
+printk(KERN_WARNING "<%s:%d, TRACE2> " format, __func__, __LINE__ , ## args);\
+  while (0)
+
+/** CAIF Trace Detailed Logging including packet dumps */
+#define CAIFLOG_TRACE3(format, args...) do if ( \
+caif_dbg_level > CAIFLOG_LEVEL_TRACE3)	\
+printk(KERN_WARNING "<%s:%d, TRACE3> " format, __func__, __LINE__ , ## args); \
+ while (0)
+
+/** CAIF Trace Entering Function */
+#define CAIFLOG_ENTER(format, args...)	do if (\
+caif_dbg_level > CAIFLOG_LEVEL_FUNC)  \
+printk(KERN_WARNING "<%s:%d, ENTER> " format, __func__, __LINE__ , ## args); \
+ while (0)
+
+/** CAIF Trace Exiting Function */
+#define CAIFLOG_EXIT(format, args...)	do if (\
+caif_dbg_level > CAIFLOG_LEVEL_FUNC)  \
+printk(KERN_WARNING "<%s:%d, EXIT> "  format, __func__, __LINE__ , ## args);\
+  while (0)
+
+#define IF_CAIF_TRACE(cmd) do if (\
+caif_dbg_level > CAIFLOG_LEVEL_TRACE) { cmd; } \
+  while (0)
+
+#endif				/*CAIF_LOG_H_ */
-- 
1.6.0.4

