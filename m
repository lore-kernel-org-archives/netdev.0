From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] checkpatch/SubmittingPatches: Suggest line wrapping
 commit messages at 75 columns
Date: Wed, 01 Apr 2015 13:33:21 -0700
Message-ID: <1427920401.31790.91.camel@perches.com>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	 <20150331.135338.519327316482059081.davem@davemloft.net>
	 <1427825806.10376.42.camel@perches.com>
	 <1427827225.18175.3.camel@perches.com>
	 <20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
	 <20150401213618.029f8c1f@lwn.net> <1427918969.31790.78.camel@perches.com>
	 <20150401131824.efafdf9c97188f97cb4a212c@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>,
	David Miller <davem@davemloft.net>,
	Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150401131824.efafdf9c97188f97cb4a212c@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit messages lines are sometimes overly long.

Suggest line wrapping at 75 columns so the default git
commit log indentation of 4 plus the commit message text
still fits on an 80 column screen.

Add a checkpatch test for long commit messages lines too.

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: David Miller <davem@davmloft.net>
---

V2: avoid Andrew Morton's colicky crying binges...

On Wed, 2015-04-01 at 13:18 -0700, Andrew Morton wrote:
> On Wed, 01 Apr 2015 13:09:29 -0700 Joe Perches <joe@perches.com> wrote:
> I'm very sensitive.

A poet too no doubt.

> > git log has a default 4 space indent of the commit message so
> > 75 or 76 would still fit an 80 column screen.
> 
> That's a good point.  Good enough to be in a changelog ;)

If you're going to change it, make sure to DTRT.

Or just take this one...

 Documentation/SubmittingPatches | 4 ++--
 scripts/checkpatch.pl           | 9 +++++++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/Documentation/SubmittingPatches b/Documentation/SubmittingPatches
index 447671b..c9de1c3 100644
--- a/Documentation/SubmittingPatches
+++ b/Documentation/SubmittingPatches
@@ -614,8 +614,8 @@ The canonical patch message body contains the following:
 
   - An empty line.
 
-  - The body of the explanation, which will be copied to the
-    permanent changelog to describe this patch.
+  - The body of the explanation, line wrapped at 75 columns, which will
+    be copied to the permanent changelog to describe this patch.
 
   - The "Signed-off-by:" lines, described above, which will
     also go in the changelog.
diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index d54a814..62a7be5 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1898,6 +1898,7 @@ sub process {
 
 	my $in_header_lines = $file ? 0 : 1;
 	my $in_commit_log = 0;		#Scanning lines before patch
+	my $commit_log_long_line = 0;
 	my $reported_maintainer_file = 0;
 	my $non_utf8_charset = 0;
 
@@ -2233,6 +2234,14 @@ sub process {
 			      "Remove Gerrit Change-Id's before submitting upstream.\n" . $herecurr);
 		}
 
+# Check for line lengths > 75 in commit log, warn once
+		if ($in_commit_log && !$commit_log_long_line &&
+		    length($line) > 75) {
+			WARN("COMMIT_LOG_LONG_LINE",
+			     "Possible unwrapped commit description (prefer a maximum 75 chars per line)\n" . $herecurr);
+			$commit_log_long_line = 1;
+		}
+
 # Check for git id commit length and improperly formed commit descriptions
 		if ($in_commit_log && $line =~ /\b(c)ommit\s+([0-9a-f]{5,})/i) {
 			my $init_char = $1;
