From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH 4/4] ip: Update man page to indicate current options.
Date: Sat, 30 Jan 2010 02:43:27 -0800
Message-ID: <20100130104326.26719.71154.stgit@localhost.localdomain>
References: <20100130104226.26719.21774.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:35615
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265Ab0A3Knq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 05:43:46 -0500
In-Reply-To: <20100130104226.26719.21774.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 man/man8/ip.8 |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 273be92..dd323a4 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -53,7 +53,21 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
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
+.IR VLANID " ] ["
+.B rate
+.IR TXRATE " ]"
+.BR " }"
+
 
 .ti -8
 .B ip link show
@@ -826,7 +840,9 @@ display and change the state of devices.
 .TP
 .BI dev " NAME " (default)
 .I NAME
-specifies network device to operate on.
+specifies network device to operate on. When configuring SR-IOV Virtual Fuction
+(VF) devices, this keyword should specify the associated Physical Function (PF)
+device.
 
 .TP
 .BR up " and " down
@@ -888,7 +904,42 @@ the interface is
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
+.BI rate " TXRATE"
+- change the allowed transmit bandwidth, in Mbps, for the specified VF.
+Setting this parameter to 0 disables rate limiting. The
+.B vf
+parameter must be specified.
+.in -8
 
 .PP
 .B Warning:

