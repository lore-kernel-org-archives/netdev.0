From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Sun, 27 Jan 2013 03:35:39 -0800
Message-ID: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following commit:
commit 058806007450489bb8f457b275e5cb5c946320c1
Author: Joe Perches <joe@perches.com>
Date:   Thu Oct 4 17:13:35 2012 -0700

checkpatch: check networking specific block comment style

Produces warnings on code comments which follow the Linux coding style
guide.  While the desired code comment style for networking my differ
from the rest of the kernel, both styles should be permitted.

This patch reverts a portion of the commit to allow multi-line code
comments to use either style.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
---
 scripts/checkpatch.pl | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 4d2c7df..d3ffec5 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1878,13 +1878,6 @@ sub process {
 		}
 
 		if ($realfile =~ m@^(drivers/net/|net/)@ &&
-		    $rawline =~ /^\+[ \t]*\/\*[ \t]*$/ &&
-		    $prevrawline =~ /^\+[ \t]*$/) {
-			WARN("NETWORKING_BLOCK_COMMENT_STYLE",
-			     "networking block comments don't use an empty /* line, use /* Comment...\n" . $hereprev);
-		}
-
-		if ($realfile =~ m@^(drivers/net/|net/)@ &&
 		    $rawline !~ m@^\+[ \t]*\*/[ \t]*$@ &&	#trailing */
 		    $rawline !~ m@^\+.*/\*.*\*/[ \t]*$@ &&	#inline /*...*/
 		    $rawline !~ m@^\+.*\*{2,}/[ \t]*$@ &&	#trailing **/
-- 
1.7.11.7
