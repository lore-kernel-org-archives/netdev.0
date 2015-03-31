From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch/SubmittingPatches: Suggest line wrapping commit
 messages at 72 columns
Date: Tue, 31 Mar 2015 11:40:25 -0700
Message-ID: <1427827225.18175.3.camel@perches.com>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	 <20150331.135338.519327316482059081.davem@davemloft.net>
	 <1427825806.10376.42.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427825806.10376.42.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit messages are sometimes overly long.
Suggest line wrapping at 72 columns.

Add a checkpatch test for long commit messages as well.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Tue, 2015-03-31 at 11:16 -0700, Joe Perches wrote:
> On Tue, 2015-03-31 at 13:53 -0400, David Miller wrote:
> > From: Ian Morris <ipm@chirality.org.uk>
> > > The following patches address some coding style issues only. No
> > > functional changes and no changes detected by objdiff.
> > >
> > > The IPV6 code uses multiple different styles when comparing with
> > > NULL (I.e. x == NULL and !x as well as x != NULL and x). Generally
> > > the latter form is preferred according to checkpatch and so this
> > > changes aligns the code to this style.
> > 
> > Please trim your commit message lines to 80 columns in the future.
> []
> > The only reliable way to edit and format commit log messages, so that
> > everyone sees something consistent, is to do so in a pure plain ASCII
> > text editor and use newlines to break columns at ~80 columns.
> 
> I think ~72 is the preferred # as by default git commit log output
> is indented a few chars.

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
+  - The body of the explanation, line wrapped at 72 columns, which will
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
 
+# Check for line lengths > 72 in commit log, warn once
+		if ($in_commit_log && !$commit_log_long_line &&
+		    length($line) > 72) {
+			WARN("COMMIT_LOG_LONG_LINE",
+			     "Possible unwrapped commit description (prefer maximum 72 chars per line)\n" . $herecurr);
+			$commit_log_long_line = 1;
+		}
+
 # Check for git id commit length and improperly formed commit descriptions
 		if ($in_commit_log && $line =~ /\b(c)ommit\s+([0-9a-f]{5,})/i) {
 			my $init_char = $1;
