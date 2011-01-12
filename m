From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 5/7] ethtool.8: Generalise references to network
 devices, not Ethernet
Date: Wed, 12 Jan 2011 16:23:03 +0000
Message-ID: <1294849383.3946.5.camel@bwh-desktop>
References: <1294849266.3946.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54149 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab1ALQXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:23:05 -0500
In-Reply-To: <1294849266.3946.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most operations are generically applicable to devices using other
link-layer protocols.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

diff --git a/ethtool.8.in b/ethtool.8.in
index 4554ca0..b7ba73e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -87,7 +87,7 @@
 
 .TH ETHTOOL 8 "January 2011" "Ethtool version @VERSION@"
 .SH NAME
-ethtool \- Display or change ethernet card settings
+ethtool \- Display or change network driver and hardware settings
 .SH SYNOPSIS
 .B ethtool
 .I ethX
@@ -322,10 +322,11 @@ ethtool \- Display or change ethernet card settings
 
 .SH DESCRIPTION
 .BI ethtool
-is used for querying settings of an ethernet device and changing them.
+is used for querying and changing settings of a network device driver
+and hardware, particularly for wired Ethernet devices.
 
 .I ethX
-is the name of the ethernet device on which ethtool should operate.
+is the name of the network device on which ethtool should operate.
 
 .SH OPTIONS
 .B ethtool
@@ -351,16 +352,16 @@ Specifies whether RX pause should be enabled.
 Specifies whether TX pause should be enabled.
 .TP
 .B \-c \-\-show\-coalesce
-Queries the specified ethernet device for coalescing information.
+Queries the specified network device for coalescing information.
 .TP
 .B \-C \-\-coalesce
-Changes the coalescing settings of the specified ethernet device.
+Changes the coalescing settings of the specified network device.
 .TP
 .B \-g \-\-show\-ring
-Queries the specified ethernet device for rx/tx ring parameter information.
+Queries the specified network device for rx/tx ring parameter information.
 .TP
 .B \-G \-\-set\-ring
-Changes the rx/tx ring parameters of the specified ethernet device.
+Changes the rx/tx ring parameters of the specified network device.
 .TP
 .BI rx \ N
 Changes the number of ring entries for the Rx ring.
@@ -375,10 +376,10 @@ Changes the number of ring entries for the Rx Jumbo ring.
 Changes the number of ring entries for the Tx ring.
 .TP
 .B \-i \-\-driver
-Queries the specified ethernet device for associated driver information.
+Queries the specified network device for associated driver information.
 .TP
 .B \-d \-\-register\-dump
-Retrieves and prints a register dump for the specified ethernet device.
+Retrieves and prints a register dump for the specified network device.
 The register format for some devices is known and decoded others
 are printed in hex.
 When 
@@ -391,13 +392,13 @@ than reading from the device.
 
 .TP
 .B \-e \-\-eeprom\-dump
-Retrieves and prints an EEPROM dump for the specified ethernet device.
+Retrieves and prints an EEPROM dump for the specified network device.
 When raw is enabled, then it dumps the raw EEPROM data to stdout. The
 length and offset parameters allow dumping certain portions of the EEPROM.
 Default is to dump the entire EEPROM.
 .TP
 .B \-E \-\-change\-eeprom
-If value is specified, changes EEPROM byte for the specified ethernet device.
+If value is specified, changes EEPROM byte for the specified network device.
 offset and value specify which byte and it's new value. If value is not
 specified, stdin is read and written to the EEPROM. The length and offset
 parameters allow writing to certain portions of the EEPROM.
@@ -405,10 +406,10 @@ Because of the persistent nature of writing to the EEPROM, a device-specific
 magic key must be specified to prevent the accidental writing to the EEPROM.
 .TP
 .B \-k \-\-show\-offload
-Queries the specified ethernet device for offload information.
+Queries the specified network device for offload information.
 .TP
 .B \-K \-\-offload
-Changes the offload parameters of the specified ethernet device.
+Changes the offload parameters of the specified network device.
 .TP
 .A2 rx on off
 Specifies whether RX checksumming should be enabled.
@@ -446,24 +447,24 @@ Specifies whether receive hashing offload should be enabled
 .B \-p \-\-identify
 Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
-blinking one or more LEDs on the specific ethernet port.
+blinking one or more LEDs on the specific network port.
 .TP
 .B N
 Length of time to perform phys-id, in seconds.
 .TP
 .B \-P \-\-show-permaddr
-Queries the specified ethernet device for permanent hardware address.
+Queries the specified network device for permanent hardware address.
 .TP
 .B \-r \-\-negotiate
 Restarts auto-negotiation on the specified ethernet device, if
 auto-negotiation is enabled.
 .TP
 .B \-S \-\-statistics
-Queries the specified ethernet device for NIC- and driver-specific
+Queries the specified network device for NIC- and driver-specific
 statistics.
 .TP
 .B \-t \-\-test
-Executes adapter selftest on the specified ethernet device. Possible test modes are:
+Executes adapter selftest on the specified network device. Possible test modes are:
 .TP
 .A1 offline online
 defines test type: 
@@ -473,7 +474,7 @@ defines test type:
 means to perform limited set of tests do not interrupting normal adapter operation.
 .TP
 .B \-s \-\-change
-Allows changing some or all settings of the specified ethernet device.
+Allows changing some or all settings of the specified network device.
 All following options only apply if
 .B \-s
 was specified.
@@ -799,7 +800,7 @@ Specifies the Rx queue to send packets to, or some other action.
 .PD
 .RE
 .SH BUGS
-Not supported (in part or whole) on all ethernet drivers.
+Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
 .B ethtool
 was written by David Miller.
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

