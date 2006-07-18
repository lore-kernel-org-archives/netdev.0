From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 04/10] MLSXFRM-v02: Add security sid to flowi
Date: Tue, 18 Jul 2006 12:24:24 -0500
Message-ID: <44BD1948.9030507@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:22177 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932315AbWGRRYj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:24:39 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds security to flow key for labeling of flows as also to allow for
making flow cache lookups based on the security label seemless.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 Documentation/networking/secid.txt |   14 ++++++++++++++
 include/net/flow.h                 |    1 +
 2 files changed, 15 insertions(+)

--- linux-2.6.17.sock/Documentation/networking/secid.txt	1969-12-31 18:00:00.000000000 -0600
+++ linux-2.6.17/Documentation/networking/secid.txt	2006-07-17 14:07:31.000000000 -0500
@@ -0,0 +1,14 @@
+flowi structure:
+
+The secid member in the flow structure is used in LSMs (e.g. SELinux) to indicate
+the label of the flow. This label of the flow is currently used in selecting
+matching labeled xfrm(s).
+
+If this is an outbound flow, the label is derived from the socket, if any, or
+the incoming packet this flow is being generated as a response to (e.g. tcp
+resets, timewait ack, etc.). It is also conceivable that the label could be
+derived from other sources such as process context, device, etc., in special
+cases, as may be appropriate.
+
+If this is an inbound flow, the label is derived from the IPSec security
+associations, if any, used by the packet.
--- linux-2.6.17.sock/include/net/flow.h	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/include/net/flow.h	2006-07-17 14:07:31.000000000 -0500
@@ -78,6 +78,7 @@ struct flowi {
 #define fl_icmp_type	uli_u.icmpt.type
 #define fl_icmp_code	uli_u.icmpt.code
 #define fl_ipsec_spi	uli_u.spi
+	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
