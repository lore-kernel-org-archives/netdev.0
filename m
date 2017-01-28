From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] man: tc-csum.8: Fix example
Date: Sat, 28 Jan 2017 12:59:10 +0100
Message-ID: <20170128115910.1127-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50611 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdA1L7R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Jan 2017 06:59:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes two issues with the provided example:

- Add missing 'dev' keyword to second command.
- Use a real IPv4 address instead of a bogus hex value since that will
  be rejected by get_addr_ipv4().

Fixes: dbfb17a67f9c7 ("man: tc-csum.8: Add an example")
Reported-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Instead of using potentially valid IP addresses, use RFC 5737 ones.
---
 man/man8/tc-csum.8 | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
index 3a64c82f09ba8..68e5610513a51 100644
--- a/man/man8/tc-csum.8
+++ b/man/man8/tc-csum.8
@@ -57,9 +57,9 @@ packets, both IP and UDP checksums have to be recalculated:
 .RS
 .EX
 # tc qdisc add dev eth0 ingress handle ffff:
-# tc filter add eth0 prio 1 protocol ip parent ffff: \\
-	u32 match ip src 192.168.1.100/32 flowid :1 \\
-	action pedit munge ip dst set 0x12345678 pipe \\
+# tc filter add dev eth0 prio 1 protocol ip parent ffff: \\
+	u32 match ip src 192.0.2.100/32 flowid :1 \\
+	action pedit munge ip dst set 198.51.100.1 pipe \\
 	csum ip and udp
 .EE
 .RE
-- 
2.11.0
