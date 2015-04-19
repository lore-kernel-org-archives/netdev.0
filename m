From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()
Date: Mon, 20 Apr 2015 00:16:56 +0200
Message-ID: <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggest using eth_zero_addr() or eth_broadcast_addr() instead of memset().

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index b9ea436..aee6d43 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5042,6 +5042,22 @@ sub process {
 			     "Prefer ether_addr_equal() or ether_addr_equal_unaligned() over memcmp()\n" . $herecurr)
 		}
 
+# check for memset(foo, 0x0, ETH_ALEN) that could be eth_zero_addr
+# check for memset(foo, 0xFF, ETH_ALEN) that could be eth_broadcast_addr
+		if ($^V && $^V ge 5.10.0 &&
+		    $line =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*ETH_ALEN\s*\)/s) {
+
+			my $ms_val = $7;
+
+			if ($ms_val =~ /^(0x|)0+$/i) {
+				WARN("PREFER_ETH_ZERO_ADDR",
+				     "Prefer eth_zero_addr over memset()\n" . $herecurr);
+			} elsif ($ms_val =~ /^(?:0xff|255)$/i) {
+				WARN("PREFER_ETH_BROADCAST_ADDR",
+				     "Prefer eth_broadcast_addr() over memset()\n" . $herecurr);
+			}
+		}
+
 # typecasts on min/max could be min_t/max_t
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
-- 
1.8.4.1
