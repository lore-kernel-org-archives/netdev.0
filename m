From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Add likely/unlikely comparison misuse test
Date: Sun, 11 Jan 2015 11:49:57 -0800
Message-ID: <1421005797.9233.3.camel@perches.com>
References: <1420999276-28225-1-git-send-email-cj@linux.com>
	 <1421002345.9233.1.camel@perches.com>
	 <20150111193404.GN1513@betelgeuse.hsd1.ma.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan <alan@linux.intel.com>, davem@davemloft.net,
	willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Jaeger <cj@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150111193404.GN1513@betelgeuse.hsd1.ma.comcast.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a test for probably likely/unlikely misuses where
the comparison is likely misplaced

	if (likely(foo) > 0)
vs
	if (likely(foo > 0))

Signed-off-by: Joe Perches <joe@perches.com>
---
On Sun, 2015-01-11 at 14:34 -0500, Christoph Jaeger wrote:
> > drivers/platform/goldfish/goldfish_pipe.c:285:	if (unlikely(bufflen) == 0)
> 
> Well, the conditional statement works as intended. Of course, the branch
> prediction doesn't.
> 
> Coccinelle should be able to check for this kind of likely()/unlikely() usage,
> shouldn't it?

Most likely,  checkpatch could too, but not as well.
This misuse isn't very common. (2 in current source?)

 scripts/checkpatch.pl | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 6afc24b..b8d47dc 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5219,6 +5219,13 @@ sub process {
 			      "#define of '$1' is wrong - use Kconfig variables or standard guards instead\n" . $herecurr);
 		}
 
+# likely/unlikely comparisons similar to "(likely(foo) > 0)"
+		if ($^V && $^V ge 5.10.0 &&
+		    $line =~ /\b((?:un)?likely)\s*\(\s*$FuncArg\s*\)\s*$Compare/) {
+			WARN("LIKELY_MISUSE",
+			     "Using $1 should generally have parentheses around the comparison\n" . $herecurr);
+		}
+
 # whine mightly about in_atomic
 		if ($line =~ /\bin_atomic\s*\(/) {
 			if ($realfile =~ m@^drivers/@) {
