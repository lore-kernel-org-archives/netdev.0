From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH v2] checkpatch: add double empty line check
Date: Sat, 17 Nov 2012 13:17:37 +0200
Message-ID: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>,
	"David Rientjes" <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Andy Whitcroft" <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes from previous attempt:
- Use CHK instead of WARN
- Issue only one warning per empty lines block

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 scripts/checkpatch.pl |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 21a9f5d..13d264f 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3579,6 +3579,14 @@ sub process {
 			WARN("EXPORTED_WORLD_WRITABLE",
 			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
 		}
+
+# check for double empty lines
+		if ($line =~ /^\+\s*$/ &&
+		    ($rawlines[$linenr] =~ /^\s*$/ ||
+		     $prevline =~ /^\+?\s*$/ && $rawlines[$linenr] !~ /^\+\s*$/)) {
+			CHK("DOUBLE_EMPTY_LINE",
+			    "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
+		}
 	}
 
 	# If we have no input at all, then there is nothing to report on
-- 
1.7.9.5
