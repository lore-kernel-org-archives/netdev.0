From: Joe Perches <joe@perches.com>
Subject: [PATCH v2] checkpatch: Allow longer logging function names
Date: Wed, 19 Jun 2013 15:49:03 -0700
Message-ID: <96448a1645250ccd9b1a301d6d65198f31a02551.1371681561.git.joe@perches.com>
References: <02874ECE860811409154E81DA85FBB585650A046@ORSMSX104.amr.corp.intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andy Whitcroft <apw@canonical.com>,
	Aaron Brown <aaron.f.brown@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <02874ECE860811409154E81DA85FBB585650A046@ORSMSX104.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jacob Keller <jacob.e.keller@intel.com>

The current $logFunction regular expression allows names like
dev_warn, e_dbg, netdev_info, etc, but some log functions are now
written like e_dev_warn, so allow 1 or 2 word blocks with an
underscore before the logging level.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
jp: Modified Jacob's patch and commit message to limit the number of
    word blocks because foo_bar_baz_dev_warn is just too long to live.

 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 7e8aa1b..1034c9b 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -280,7 +280,7 @@ our $typeTypedefs = qr{(?x:
 
 our $logFunctions = qr{(?x:
 	printk(?:_ratelimited|_once|)|
-	[a-z0-9]+_(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
+	(?:[a-z0-9]+_){1,2}(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
 	WARN(?:_RATELIMIT|_ONCE|)|
 	panic|
 	MODULE_[A-Z_]+
-- 
1.8.1.2.459.gbcd45b4.dirty
