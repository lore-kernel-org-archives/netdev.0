From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 11/12] net-caif: add CAIF documentation
Date: Wed, 31 Mar 2010 01:56:29 +0200
Message-ID: <1269993390-23830-12-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-8-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-9-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-10-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-11-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359Ab0C3X5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:21 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CCOD6WAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:56 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:56 +0200 (CEST)
In-reply-to: <1269993390-23830-11-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Documentation of the CAIF Protocol.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 Documentation/networking/caif/Linux-CAIF.txt |  212 ++++++++++++++++++++++++++
 Documentation/networking/caif/README         |  109 +++++++++++++
 2 files changed, 321 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/caif/Linux-CAIF.txt b/Documentation/networking/caif/Linux-CAIF.txt
new file mode 100644
index 0000000..7fe7a9a
--- /dev/null
+++ b/Documentation/networking/caif/Linux-CAIF.txt
@@ -0,0 +1,212 @@
+Linux CAIF
+===========
+copyright (C) ST-Ericsson AB 2010
+Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+License terms: GNU General Public License (GPL) version 2
+
+
+Introduction
+------------
+CAIF is a MUX protocol used by ST-Ericsson cellular modems for
+communication between Modem and host. The host processes can open virtual AT
+channels, initiate GPRS Data connections, Video channels and Utility Channels.
+The Utility Channels are general purpose pipes between modem and host.
+
+ST-Ericsson modems support a number of transports between modem
+and host. Currently, UART and Loopback are available for Linux.
+
+
+Architecture:
+------------
+The implementation of CAIF is divided into:
+* CAIF Socket Layer, Kernel API, and  Net Device.
+* CAIF Core Protocol Implementation
+* CAIF Link Layer, implemented as NET devices.
+
+
+  RTNL
+   !
+   !	 +------+   +------+   +------+
+   !	+------+!  +------+!  +------+!
+   !	! Sock !!  !Kernel!!  ! Net  !!
+   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF Client APIs
+   !	+------+   +------!   +------+
+   !	   !	      !		 !
+   !	   +----------!----------+
+   !		   +------+		  <- CAIF Protocol Implementation
+   +------->	   ! CAIF !
+		   ! Core !
+		   +------+
+	     +--------!--------+
+	     !		       !
+	  +------+	    +-----+
+	  !    	 !	    ! TTY !	  <- Link Layer (Net Devices)
+	  +------+	    +-----+
+
+
+Using the Kernel API
+----------------------
+The Kernel API is used for accessing CAIF channels from the
+kernel.
+The user of the API has to implement two callbacks for receive
+and control.
+The receive callback gives a CAIF packet as a SKB. The control
+callback will
+notify of channel initialization complete, and flow-on/flow-
+off.
+
+
+  struct caif_device caif_dev = {
+    .caif_config = {
+     .name = "MYDEV"
+     .type = CAIF_CHTY_AT
+    }
+   .receive_cb = my_receive,
+   .control_cb = my_control,
+  };
+  caif_add_device(&caif_dev);
+  caif_transmit(&caif_dev, skb);
+
+See the caif_kernel.h for details about the CAIF kernel API.
+
+
+I M P L E M E N T A T I O N
+===========================
+===========================
+
+CAIF Core Protocol Layer
+=========================================
+
+CAIF Core layer implements the CAIF protocol as defined by ST-Ericsson.
+It implements the CAIF protocol stack in a layered approach, where
+each layer described in the specification is implemented as a separate layer.
+The architecture is inspired by the design patterns "Protocol Layer" and
+"Protocol Packet".
+
+== CAIF structure ==
+The Core CAIF implementation contains:
+      -	Simple implementation of CAIF.
+      -	Layered architecture (a la Streams), each layer in the CAIF
+	specification is implemented in a separate c-file.
+      -	Clients must implement PHY layer to access physical HW
+	with receive and transmit functions.
+      -	Clients must call configuration function to add PHY layer.
+      -	Clients must implement CAIF layer to consume/produce
+	CAIF payload with receive and transmit functions.
+      -	Clients must call configuration function to add and connect the
+	Client layer.
+      - When receiving / transmitting CAIF Packets (cfpkt), ownership is passed
+	to the called function (except for framing layers' receive functions
+	or if a transmit function returns an error, in which case the caller
+	must free the packet).
+
+Layered Architecture
+--------------------
+The CAIF protocol can be divided into two parts: Support functions and Protocol
+Implementation. The support functions include:
+
+      - CFPKT CAIF Packet. Implementation of CAIF Protocol Packet. The
+	CAIF Packet has functions for creating, destroying and adding content
+	and for adding/extracting header and trailers to protocol packets.
+
+      - CFLST CAIF list implementation.
+
+      - CFGLUE CAIF Glue. Contains OS Specifics, such as memory
+	allocation, endianness, etc.
+
+The CAIF Protocol implementation contains:
+
+      - CFCNFG CAIF Configuration layer. Configures the CAIF Protocol
+	Stack and provides a Client interface for adding Link-Layer and
+	Driver interfaces on top of the CAIF Stack.
+
+      - CFCTRL CAIF Control layer. Encodes and Decodes control messages
+	such as enumeration and channel setup. Also matches request and
+	response messages.
+
+      - CFSERVL General CAIF Service Layer functionality; handles flow
+	control and remote shutdown requests.
+
+      - CFVEI CAIF VEI layer. Handles CAIF AT Channels on VEI (Virtual
+        External Interface). This layer encodes/decodes VEI frames.
+
+      - CFDGML CAIF Datagram layer. Handles CAIF Datagram layer (IP
+	traffic), encodes/decodes Datagram frames.
+
+      - CFMUX CAIF Mux layer. Handles multiplexing between multiple
+	physical bearers and multiple channels such as VEI, Datagram, etc.
+	The MUX keeps track of the existing CAIF Channels and
+	Physical Instances and selects the apropriate instance based
+	on Channel-Id and Physical-ID.
+
+      - CFFRML CAIF Framing layer. Handles Framing i.e. Frame length
+	and frame checksum.
+
+      - CFSERL CAIF Serial layer. Handles concatenation/split of frames
+	into CAIF Frames with correct length.
+
+
+
+		    +---------+
+		    | Config  |
+		    | CFCNFG  |
+		    +---------+
+			 !
+    +---------+	    +---------+	    +---------+
+    |	AT    |	    | Control |	    | Datagram|
+    | CFVEIL  |	    | CFCTRL  |	    | CFDGML  |
+    +---------+	    +---------+	    +---------+
+	   \_____________!______________/
+			 !
+		    +---------+
+		    |	MUX   |
+		    |	      |
+		    +---------+
+		    _____!_____
+		   /	       \
+	    +---------+	    +---------+
+	    | CFFRML  |	    | CFFRML  |
+	    | Framing |	    | Framing |
+	    +---------+	    +---------+
+		 !		!
+	    +---------+	    +---------+
+	    |         |	    | Serial  |
+	    |	      |	    | CFSERL  |
+	    +---------+	    +---------+
+
+
+In this layered approach the following "rules" apply.
+      - All layers embed the same structure "struct cflayer"
+      - A layer does not depend on any other layer's private data.
+      - Layers are stacked by setting the pointers
+		  layer->up , layer->dn
+      -	In order to send data upwards, each layer should do
+		 layer->up->receive(layer->up, packet);
+      - In order to send data downwards, each layer should do
+		 layer->dn->transmit(layer->dn, packet);
+
+
+Linux Driver Implementation
+===========================
+
+Linux GPRS Net Device and CAIF socket are implemented on top of the
+CAIF Core protocol. The Net device and CAIF socket have an instance of
+'struct cflayer', just like the CAIF Core protocol stack.
+Net device and Socket implement the 'receive()' function defined by
+'struct cflayer', just like the rest of the CAIF stack. In this way, transmit and
+receive of packets is handled as by the rest of the layers: the 'dn->transmit()'
+function is called in order to transmit data.
+
+The layer on top of the CAIF Core implementation is
+sometimes referred to as the "Client layer".
+
+
+Configuration of Link Layer
+---------------------------
+The Link Layer is implemented as Linux net devices (struct net_device).
+Payload handling and registration is done using standard Linux mechanisms.
+
+The CAIF Protocol relies on a loss-less link layer without implementing
+retransmission. This implies that packet drops must not happen.
+Therefore a flow-control mechanism is implemented where the physical
+interface can initiate flow stop for all CAIF Channels.
diff --git a/Documentation/networking/caif/README b/Documentation/networking/caif/README
new file mode 100644
index 0000000..757ccfa
--- /dev/null
+++ b/Documentation/networking/caif/README
@@ -0,0 +1,109 @@
+Copyright (C) ST-Ericsson AB 2010
+Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+License terms: GNU General Public License (GPL) version 2
+---------------------------------------------------------
+
+=== Start ===
+If you have compiled CAIF for modules do:
+
+$modprobe crc_ccitt
+$modprobe caif
+$modprobe caif_socket
+$modprobe chnl_net
+
+
+=== Preparing the setup with a STE modem ===
+
+If you are working on integration of CAIF you should make sure
+that the kernel is built with module support.
+
+There are some things that need to be tweaked to get the host TTY correctly
+set up to talk to the modem.
+Since the CAIF stack is running in the kernel and we want to use the existing
+TTY, we are installing our physical serial driver as a line discipline above
+the TTY device.
+
+To achieve this we need to install the N_CAIF ldisc from user space.
+The benefit is that we can hook up to any TTY.
+
+The use of Start-of-frame-extension (STX) must also be set as
+module parameter "ser_use_stx".
+
+Normally Frame Checksum is always used on UART, but this is also provided as a
+module parameter "ser_use_fcs".
+
+$ modprobe caif_serial ser_ttyname=/dev/ttyS0 ser_use_stx=yes
+$ ifconfig caif_ttyS0 up
+
+PLEASE NOTE: 	There is a limitation in Android shell.
+		It only accepts one argument to insmod/modprobe!
+
+=== Trouble shooting ===
+
+There are debugfs parameters provided for serial communication.
+/sys/kernel/debug/caif_serial/<tty-name>/
+
+* ser_state:   Prints the bit-mask status where
+  - 0x02 means SENDING, this is a transient state.
+  - 0x10 means FLOW_OFF_SENT, i.e. the previous frame has not been sent
+	and is blocking further send operation. Flow OFF has been propagated
+	to all CAIF Channels using this TTY.
+
+* tty_status: Prints the bit-mask tty status information
+  - 0x01 - tty->warned is on.
+  - 0x02 - tty->low_latency is on.
+  - 0x04 - tty->packed is on.
+  - 0x08 - tty->flow_stopped is on.
+  - 0x10 - tty->hw_stopped is on.
+  - 0x20 - tty->stopped is on.
+
+* last_tx_msg: Binary blob Prints the last transmitted frame.
+	This can be printed with
+	$od --format=x1 /sys/kernel/debug/caif_serial/<tty>/last_rx_msg.
+	The first two tx messages sent look like this. Note: The initial
+	byte 02 is start of frame extension (STX) used for re-syncing
+	upon errors.
+
+  - Enumeration:
+        0000000  02 05 00 00 03 01 d2 02
+                 |  |     |  |  |  |
+                 STX(1)   |  |  |  |
+                    Length(2)|  |  |
+                          Control Channel(1)
+                             Command:Enumeration(1)
+                                Link-ID(1)
+                                    Checksum(2)
+  - Channel Setup:
+        0000000  02 07 00 00 00 21 a1 00 48 df
+                 |  |     |  |  |  |  |  |
+                 STX(1)   |  |  |  |  |  |
+                    Length(2)|  |  |  |  |
+                          Control Channel(1)
+                             Command:Channel Setup(1)
+                                Channel Type(1)
+                                    Priority and Link-ID(1)
+				      Endpoint(1)
+					  Checksum(2)
+
+* last_rx_msg: Prints the last transmitted frame.
+	The RX messages for LinkSetup look almost identical but they have the
+	bit 0x20 set in the command bit, and Channel Setup has added one byte
+	before Checksum containing Channel ID.
+	NOTE: Several CAIF Messages might be concatenated. The maximum debug
+	buffer size is 128 bytes.
+
+== Error Scenarios:
+- last_tx_msg contains channel setup message and last_rx_msg is empty ->
+  The host seems to be able to send over the UART, at least the CAIF ldisc get
+  notified that sending is completed.
+
+- last_tx_msg contains enumeration message and last_rx_msg is empty ->
+  The host is not able to send the message from UART, the tty has not been
+  able to complete the transmit operation.
+
+- if /sys/kernel/debug/caif_serial/<tty>/tty_status is non-zero there
+  might be problems transmitting over UART.
+  E.g. host and modem wiring is not correct you will typically see
+  tty_status = 0x10 (hw_stopped) and ser_state = 0x10 (FLOW_OFF_SENT).
+  You will probably see the enumeration message in last_tx_message
+  and empty last_rx_message.
-- 
1.6.3.3

