From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH v2 4/4] Update man page to indicate current options
Date: Wed, 10 Feb 2010 03:47:29 -0800
Message-ID: <20100210114729.14570.6713.stgit@localhost.localdomain>
References: <20100210114617.14570.87620.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:54317
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754695Ab0BJLrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:47:49 -0500
In-Reply-To: <20100210114617.14570.87620.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 man/man8/ip.8 |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index ccc800f..3efa045 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -53,7 +53,23 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .IR MTU " |"
 .br
 .B  netns
-.IR PID " }"
+.IR PID " |"
+.br
+.B alias
+.IR NAME  " |"
+.br
+.B vf
+.IR NUM " ["
+.B  mac
+.IR LLADDR " ] ["
+.B vlan
+.IR VLANID " [ "
+.B qos
+.IR VLAN-QOS " ] ] ["
+.B rate
+.IR TXRATE " ]"
+.BR " }"
+
 
 .ti -8
 .B ip link show
@@ -822,7 +838,9 @@ display and change the state of devices.
 .TP
 .BI dev " NAME " (default)
 .I NAME
-specifies network device to operate on.
+specifies network device to operate on. When configuring SR-IOV Virtual Fuction
+(VF) devices, this keyword should specify the associated Physical Function (PF)
+device.
 
 .TP
 .BR up " and " down
@@ -884,7 +902,56 @@ the interface is
 .TP
 .BI netns " PID"
 move the device to the network namespace associated with the process
-.IR "PID" .
+.IR "PID".
+
+.TP
+.BI alias " NAME"
+give the device a symbolic name for easy reference.
+
+.TP
+.BI vf " NUM"
+specify a Virtual Function device to be configured. The associated PF device
+must be specified using the
+.B dev
+parameter.
+
+.in +8
+.BI mac " LLADDRESS"
+- change the station address for the specified VF. The
+.B vf
+parameter must be specified.
+
+.sp
+.BI vlan " VLANID"
+- change the assigned VLAN for the specified VF. When specified, all traffic
+sent from the VF will be tagged with the specified VLAN ID. Incoming traffic
+will be filtered for the specified VLAN ID, and will have all VLAN tags
+stripped before being passed to the VF. Setting this parameter to 0 disables
+VLAN tagging and filtering. The
+.B vf
+parameter must be specified.
+
+.sp
+.BI qos " VLAN-QOS"
+- assign VLAN QOS (priority) bits for the VLAN tag. When specified, all VLAN
+tags transmitted by the VF will include the specified priority bits in the
+VLAN tag. If not specified, the value is assumed to be 0. Both the
+.B vf
+and
+.B vlan
+parameters must be specified. Setting both
+.B vlan
+and
+.B qos
+as 0 disables VLAN tagging and filtering for the VF.
+
+.sp
+.BI rate " TXRATE"
+- change the allowed transmit bandwidth, in Mbps, for the specified VF.
+Setting this parameter to 0 disables rate limiting. The
+.B vf
+parameter must be specified.
+.in -8
 
 .PP
 .B Warning:

