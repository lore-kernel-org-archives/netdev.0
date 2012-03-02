From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Add --strict test for strings split across
 multiple lines
Date: Thu, 01 Mar 2012 21:54:33 -0800
Message-ID: <1330667673.1939.22.camel@joe2Laptop>
References: <20120302025554.GA13493@joana>
	 <20120301.221643.881299898523907213.davem@davemloft.net>
	 <20120301.222316.1877216960521396397.davem@davemloft.net>
	 <20120301.222604.1508242694024394849.davem@davemloft.net>
	 <1330661602.1939.13.camel@joe2Laptop> <1330666534.1939.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>, gustavo@padovan.org,
	johan.hedberg@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330666534.1939.19.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Strings split across multiple lines are commonly used
as formats.  These uncoalesced formats are hard to grep
and are relatively error prone.

Suggest coalescing split strings when using --strict.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 581a14c..5d0b46c 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1860,6 +1860,12 @@ sub process {
 			    "Don't begin block comments with only a /* line, use /* comment...\n" . $hereprev);
 		}
 
+		if ($prevline =~ /^\+.*"[ \t]*$/ &&
+		    $line =~ /^\+[ \t]*"/) {
+			CHK("COALESCE_STRING",
+			    "Coalesced strings are easier to grep and less error prone\n" . $hereprev);
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
-- 
1.7.8.111.gad25c.dirty
