From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Improve network block comment style checking
Date: Sun, 14 Oct 2012 12:35:58 -0700
Message-ID: <1350243358.22442.13.camel@joe-AO722>
References: <5078603C.9010709@lwfinger.net>
	 <1350067114.2243.35.camel@joe-AO722> <50787432.8030805@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50787432.8030805@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some comment styles in net and drivers/net are flagged inappropriately.

Avoid proclaiming inline comments like:
	int a = b;	/* some comment */
and block comments like:
	/*********************
	 * some comment
	 ********************/
are defective.

Tested with
$ cat drivers/net/t.c
/* foo */

/*
 * foo
 */

/* foo
 */

/* foo
 * bar */

/****************************
 * some long block comment
 ***************************/

struct foo {
	int bar;	/* another test */
};
$

Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 21a9f5d..f18750e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1890,8 +1890,10 @@ sub process {
 		}
 
 		if ($realfile =~ m@^(drivers/net/|net/)@ &&
-		    $rawline !~ m@^\+[ \t]*(\/\*|\*\/)@ &&
-		    $rawline =~ m@^\+[ \t]*.+\*\/[ \t]*$@) {
+		    $rawline !~ m@^\+[ \t]*\*/[ \t]*$@ &&	#trailing */
+		    $rawline !~ m@^\+.*/\*.*\*/[ \t]*$@ &&	#inline /*...*/
+		    $rawline !~ m@^\+.*\*{2,}/[ \t]*$@ &&	#trailing **/
+		    $rawline =~ m@^\+[ \t]*.+\*\/[ \t]*$@) {	#non blank */
 			WARN("NETWORKING_BLOCK_COMMENT_STYLE",
 			     "networking block comments put the trailing */ on a separate line\n" . $herecurr);
 		}
