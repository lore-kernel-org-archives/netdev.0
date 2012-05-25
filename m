From: Rostislav Lisovy <lisovy@gmail.com>
Subject: [PATCH iproute2 3/3] CAN Filter/Classifier -- Documentation
Date: Fri, 25 May 2012 11:11:46 +0200
Message-ID: <1337937106-7640-4-git-send-email-lisovy@gmail.com>
References: <1337937106-7640-1-git-send-email-lisovy@gmail.com>
Cc: linux-can@vger.kernel.org, pisa@cmp.felk.cvut.cz,
	sojkam1@fel.cvut.cz, oliver@hartkopp.net,
	Rostislav Lisovy <lisovy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1337937106-7640-1-git-send-email-lisovy@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added manpage describing usage of CAN Filter.

Signed-off-by: Rostislav Lisovy <lisovy@gmail.com>
---
 man/man8/tc-can.8 |   97 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)
 create mode 100644 man/man8/tc-can.8

diff --git a/man/man8/tc-can.8 b/man/man8/tc-can.8
new file mode 100644
index 0000000..54ee96a
--- /dev/null
+++ b/man/man8/tc-can.8
@@ -0,0 +1,97 @@
+.TH CAN 8 "8 May 2012" "iproute2" "Linux"
+.SH NAME
+CAN \- Controller Area Network classifier
+.SH SYNOPSIS
+.B tc filter ... dev
+DEV
+.B parent
+CLASSID
+.B [ prio
+PRIORITY
+.B ] [ protocol can ] [ handle 
+HANDLE
+.B ] can [ 
+MATCHSPEC
+.B ] [ flowid 
+FLOWID
+.B ]
+
+.B CLASSID := major:minor
+.br
+.B FLOWID := major:minor
+.br
+.B MATCHSPEC := { sffid 
+FILTERID
+.B | effid 
+FILTERID
+.B | MATCHSPEC ... }
+.br
+.B FILTERID := canid[:mask]
+
+.BR CLASSID ,
+.BR FLOWID ,
+.BR canid
+and
+.B mask
+are parsed as hexadecimal input.
+
+
+.SH DESCRIPTION
+The CAN classifier may be used with any available
+.B qdisc
+on Controller Area Network (CAN) frames passed through AF_CAN
+networking subsystem. The classifier classifies CAN frames according
+to their identifiers. It can be used on CAN frames with both SFF or
+EFF identifiers.
+
+It is possible to add CAN classifier to any qdisc configured on any networking
+device, however it will ignore non-CAN packets.
+
+
+.SH CLASSIFICATION
+The filtering rules for EFF frames are stored in an array, which is traversed
+during classification. This means that the worst-case time needed for
+classification of EFF frames increases with the number of configured rules.
+
+The filter implements an optimization for matching SFF frames using a bitmap
+with one bit for every ID. With this optimization, the classification time
+for SFF frames is nearly constant independently of the number of rules.
+
+.SH EXAMPLE
+This example shows how to set
+.B prio qdisc
+with
+.B CAN
+classifier.
+
+.nf
+tc qdisc add dev can0 root handle 1: prio
+
+tc filter add dev can0 parent 1:0 prio 1 handle 0xa \\
+    can sffid 0x7ff:0xf flowid 1:1
+tc filter add dev can0 parent 1:0 prio 2 handle 0xb \\
+    can sffid 0xC0:0x7ff effid 0x80:0x7ff flowid 1:2
+tc filter add dev can0 parent 1:0 prio 3 \\
+    can sffid 0x80:0x7ff flowid 1:2
+tc filter add dev can0 parent 1:0 prio 4 \\
+    can sffid 0x0:0x0 effid 0x0:0x0 flowid 1:3
+.fi
+
+
+.SH BUGS
+The maximum number or rules passed from
+.BR tc(8)
+utility to CAN classifier is fixed. The limit is set at compilation time
+(default is 128).
+
+
+.SH SEE ALSO
+.BR tc(8)
+
+
+.SH AUTHORS
+Michal Sojka <sojkam1@fel.cvut.cz>, Pavel Pisa <pisa@cmp.felk.cvut.cz>,
+Rostislav Lisovy <lisovy@gmail.cz>.
+
+This manpage maintained by Rostislav Lisovy <lisovy@gmail.com>
+
-- 
1.7.9.5

