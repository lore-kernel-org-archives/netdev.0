From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: See if modified files are marked obsolete in MAINTAINERS
Date: Mon, 22 Aug 2016 11:17:20 -0700
Message-ID: <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
References: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Andy Whitcroft <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use get_maintainer to check the status of individual files.
If "obsolete", suggest leaving the files alone.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 4de3cc4..df5e9d9 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -704,6 +704,16 @@ sub seed_camelcase_file {
 	}
 }
 
+sub is_maintained_obsolete {
+	my ($filename) = @_;
+
+	return 0 if (!(-e "$root/scripts/get_maintainer.pl"));
+
+	my $status = `perl $root/scripts/get_maintainer.pl --status --nom --nol --nogit --nogit-fallback $filename 2>&1`;
+
+	return $status =~ /obsolete/i;
+}
+
 my $camelcase_seeded = 0;
 sub seed_camelcase_includes {
 	return if ($camelcase_seeded);
@@ -2289,6 +2299,10 @@ sub process {
 		}
 
 		if ($found_file) {
+			if (is_maintained_obsolete($realfile)) {
+				WARN("OBSOLETE",
+				     "$realfile is marked as 'obsolete' in the MAINTAINERS hierarchy.  No unnecessary modifications please.\n");
+			}
 			if ($realfile =~ m@^(?:drivers/net/|net/|drivers/staging/)@) {
 				$check = 1;
 			} else {
-- 
2.8.0.rc4.16.g56331f8
