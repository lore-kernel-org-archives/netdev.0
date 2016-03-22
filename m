From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/8] man: tc-csum.8: Add an example
Date: Tue, 22 Mar 2016 15:48:34 +0100
Message-ID: <1458658119-25881-4-git-send-email-phil@nwl.cc>
References: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55796 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932616AbcCVOs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:48:58 -0400
In-Reply-To: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-csum.8 | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
index 9d00aae346af0..3a64c82f09ba8 100644
--- a/man/man8/tc-csum.8
+++ b/man/man8/tc-csum.8
@@ -49,6 +49,21 @@ UDPLite header
 .TP
 .B SWEETS
 These are merely syntactic sugar and ignored internally.
+.SH EXAMPLES
+The following performs stateless NAT for incoming packets from 192.168.1.100 to
+new destination 18.52.86.120 (0x12345678 in hex). Assuming these are UDP
+packets, both IP and UDP checksums have to be recalculated:
+
+.RS
+.EX
+# tc qdisc add dev eth0 ingress handle ffff:
+# tc filter add eth0 prio 1 protocol ip parent ffff: \\
+	u32 match ip src 192.168.1.100/32 flowid :1 \\
+	action pedit munge ip dst set 0x12345678 pipe \\
+	csum ip and udp
+.EE
+.RE
+
 .SH SEE ALSO
 .BR tc (8),
 .BR tc-pedit (8)
-- 
2.7.2
