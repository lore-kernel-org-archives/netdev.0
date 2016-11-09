From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v9 7/8] thunderbolt: Networking doc
Date: Wed,  9 Nov 2016 16:20:07 +0200
Message-ID: <1478701208-4585-8-git-send-email-amir.jer.levy@intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43552 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753816AbcKIMVL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:21:11 -0500
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Thunderbolt(TM) networking documentation.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 Documentation/00-INDEX                   |   2 +
 Documentation/thunderbolt/networking.txt | 132 +++++++++++++++++++++++++++++++
 2 files changed, 134 insertions(+)
 create mode 100644 Documentation/thunderbolt/networking.txt

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index 3acc4f1..0239e68 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -440,6 +440,8 @@ this_cpu_ops.txt
 	- List rationale behind and the way to use this_cpu operations.
 thermal/
 	- directory with information on managing thermal issues (CPU/temp)
+thunderbolt/
+	- directory with info regarding Thunderbolt.
 trace/
 	- directory with info on tracing technologies within linux
 unaligned-memory-access.txt
diff --git a/Documentation/thunderbolt/networking.txt b/Documentation/thunderbolt/networking.txt
new file mode 100644
index 0000000..88d1c12
--- /dev/null
+++ b/Documentation/thunderbolt/networking.txt
@@ -0,0 +1,132 @@
+Intel Thunderbolt(TM) Networking driver
+=======================================
+
+Copyright(c) 2013 - 2016 Intel Corporation.
+
+Contact Information:
+Intel Thunderbolt mailing list <thunderbolt-software@lists.01.org>
+Edited by Amir Levy <amir.jer.levy@intel.com>
+
+Overview
+========
+
+* The Thunderbolt Networking driver enables peer to peer networking on non-Apple
+  platforms running Linux.
+
+* The driver creates a virtual Ethernet device that enables computer to computer
+  communication over the Thunderbolt cable.
+
+* Using Thunderbolt Networking you can perform high speed file transfers between
+  computers, perform PC migrations and/or set up small workgroups with shared
+  storage without compromising any other Thunderbolt functionality.
+
+* The driver is located in drivers/thunderbolt/icm.
+
+* This driver will function only on non-Apple platforms with firmware based
+  Thunderbolt controllers that support Thunderbolt Networking.
+
+  +----------------+            +----------------+
+  |Host 1          |            |Host 2          |
+  |                |            |                |
+  |   +-------+    |            |    +-------+   |
+  |   |Network|    |            |    |Network|   |
+  |   |Stack  |    |            |    |Stack  |   |
+  |   +-------+    |            |    +-------+   |
+  |       ^        |            |        ^       |
+  |       |        |            |        |       |
+  |       v        |            |        v       |
+  | +-----------+  |            |  +-----------+ |
+  | |Thunderbolt|  |            |  |Thunderbolt| |
+  | |Networking |  |            |  |Networking | |
+  | |Driver     |  |            |  |Driver     | |
+  | +-----------+  |            |  +-----------+ |
+  |       ^        |            |        ^       |
+  |       |        |            |        |       |
+  |       v        |            |        v       |
+  | +-----------+  |            |  +-----------+ |
+  | |Thunderbolt|  |            |  |Thunderbolt| |
+  | |Controller |<-+------------+->|Controller | |
+  | |with ICM   |  |            |  |with ICM   | |
+  | |enabled    |  |            |  |enabled    | |
+  | +-----------+  |            |  +-----------+ |
+  +----------------+            +----------------+
+
+Files
+=====
+
+The following files are located in the drivers/thunderbolt/icm directory:
+
+- icm_nhi.c/h:	These files allow communication with the firmware (Intel
+  Connection Manager) based controller. They also create an interface for
+  netlink communication with a user space daemon.
+
+- net.c/net.h:	These files implement the 'eth' interface for the
+  Thunderbolt(TM) Networking.
+
+Interface to User Space
+=======================
+
+The interface to the user space module is implemented through a Generic Netlink.
+This is the communications protocol between the Thunderbolt driver and the user
+space application.
+
+Note that this interface mediates user space communication with ICM.
+(Existing Linux tools can be used to configure the network interface.)
+
+The Thunderbolt Daemon utilizes this interface to communicate with the driver.
+To be accessed by the user space module, both kernel and user space modules
+have to register with the same GENL_NAME.
+For the purpose of the Thunderbolt Network driver, "thunderbolt" is used.
+The registration is done at driver initialization time for all instances
+of the Thunderbolt controllers. The communication is carried through pre-defined
+Thunderbolt messages. Each specific message has a callback function that is
+called when the related message is received.
+
+Message Definitions:
+* NHI_CMD_UNSPEC: Not used.
+* NHI_CMD_SUBSCRIBE: Subscription request from daemon to driver to open the
+  communication channel.
+* NHI_CMD_UNSUBSCRIBE: Request from daemon to driver to unsubscribe and
+  to close communication channel.
+* NHI_CMD_QUERY_INFORMATION: Request information from the driver such as
+  driver version, FW version offset, number of ports in the controller
+  and DMA port.
+* NHI_CMD_MSG_TO_ICM: Message from user space module to FW.
+* NHI_CMD_MSG_FROM_ICM: Response from FW to user space module.
+* NHI_CMD_MAILBOX: Message that uses mailbox mechanism such as FW policy
+  changes or disconnect path.
+* NHI_CMD_APPROVE_TBT_NETWORKING: Request from user space module to FW to
+  establish path.
+* NHI_CMD_ICM_IN_SAFE_MODE: Indication that the FW has entered safe mode.
+
+Communication with Intel Connection Manager(ICM) Firmware
+=========================================================
+
+There are several circular buffers in Thunderbolt each using Direct Memory
+Access (DMA).
+
+Communication with ICM utilizes circular buffer ring #0. (The other rings are
+used for peer to peer communication, packet transmission and receiving).
+
+The driver allocates a shared memory that is physically mapped onto the DMA
+physical space at ring #0.
+For the software to communicate with the firmware, the driver sends a command
+in ring #0. The command contains a pre-defined field (PDF) value notifying the
+firmware that the driver is ready. To proceed, the driver must receive the
+appropriate PDF value in response from the firmware.
+
+Once the exchange is completed, messages can be sent to the firmware through
+the driver. Similarly, the firmware can now send notifications about hardware
+and firmware events.
+
+Information
+===========
+
+Mailing list:
+	thunderbolt-software@lists.01.org
+	Register at: https://lists.01.org/mailman/listinfo/thunderbolt-software
+	Archives at: https://lists.01.org/pipermail/thunderbolt-software/
+
+For additional information about Thunderbolt technology visit:
+	https://01.org/thunderbolt-sw
+	https://thunderbolttechnology.net/
-- 
2.7.4
