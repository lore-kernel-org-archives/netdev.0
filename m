From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Make --strict a default for files in drivers/net and net/
Date: Wed,  7 May 2014 11:13:26 -0700
Message-ID: <487acde009f61607863704e5dd9da7f151cf5be8.1399486274.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andy Whitcroft <apw@canonical.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking files are generally more strictly conformant to
linux-kernel style so make checkpatch more verbose by default for
patches to files or when checking files in these directories.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 85fc923..633e9f6 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -24,6 +24,7 @@ my $emacs = 0;
 my $terse = 0;
 my $file = 0;
 my $check = 0;
+my $check_orig = 0;
 my $summary = 1;
 my $mailback = 0;
 my $summary_file = 0;
@@ -146,6 +147,7 @@ GetOptions(
 help(0) if ($help);
 
 $fix = 1 if ($fix_inplace);
+$check_orig = $check;
 
 my $exit = 0;
 
@@ -1813,11 +1815,13 @@ sub process {
 		$here = "#$linenr: " if (!$file);
 		$here = "#$realline: " if ($file);
 
+		my $found_file = 0;
 		# extract the filename as it passes
 		if ($line =~ /^diff --git.*?(\S+)$/) {
 			$realfile = $1;
 			$realfile =~ s@^([^/]*)/@@ if (!$file);
 			$in_commit_log = 0;
+			$found_file = 1;
 		} elsif ($line =~ /^\+\+\+\s+(\S+)/) {
 			$realfile = $1;
 			$realfile =~ s@^([^/]*)/@@ if (!$file);
@@ -1834,6 +1838,15 @@ sub process {
 				ERROR("MODIFIED_INCLUDE_ASM",
 				      "do not modify files in include/asm, change architecture specific files in include/asm-<architecture>\n" . "$here$rawline\n");
 			}
+			$found_file = 1;
+		}
+
+		if ($found_file) {
+			if ($realfile =~ m@^(drivers/net/|net/)@) {
+				$check = 1;
+			} else {
+				$check = $check_orig;
+			}
 			next;
 		}
 
-- 
1.8.1.2.459.gbcd45b4.dirty
