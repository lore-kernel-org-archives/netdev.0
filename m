From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Fix networking kernel-doc block comment defect
Date: Wed, 24 Jul 2013 20:31:52 -0700
Message-ID: <1374723112.1924.41.camel@joe-AO722>
References: <b939bb41630693171771c108801c1c5f688ecabc.1374525261.git.dvhart@linux.intel.com>
	 <cover.1374525261.git.dvhart@linux.intel.com>
	 <79241b53ec4e638008ba3384958ef9901ad11338.1374525261.git.dvhart@linux.intel.com>
	 <20130724.170008.924195436945641752.davem@davemloft.net>
	 <1374711603.3436.246.camel@dvhart-mobl1.amr.corp.intel.com>
	 <1374712895.1924.13.camel@joe-AO722>
	 <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
	 <1374721731.1924.34.camel@joe-AO722>
	 <1374722064.3436.252.camel@dvhart-mobl1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Andy Whitcroft <apw@canonical.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50548 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753343Ab3GYDby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 23:31:54 -0400
In-Reply-To: <1374722064.3436.252.camel@dvhart-mobl1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch can generate a false positive when inserting
a new kernel-doc block and function above an existing
kernel-doc block.

Fix it by checking that the context line is also a newly
inserted line.

Reported-by: Darren Hart <dvhart@linux.intel.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 1 +
 1 file changed, 1 insertion(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 23126d4..c18e1be 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2074,6 +2074,7 @@ sub process {
 		if ($realfile =~ m@^(drivers/net/|net/)@ &&
 		    $prevrawline =~ /^\+[ \t]*\/\*/ &&		#starting /*
 		    $prevrawline !~ /\*\/[ \t]*$/ &&		#no trailing */
+		    $rawline =~ /^\+/ &&			#line is new
 		    $rawline !~ /^\+[ \t]*\*/) {		#no leading *
 			WARN("NETWORKING_BLOCK_COMMENT_STYLE",
 			     "networking block comments start with * on subsequent lines\n" . $hereprev);
-- 
1.8.1.2.459.gbcd45b4.dirty
