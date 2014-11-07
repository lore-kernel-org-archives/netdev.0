From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Add --strict preference for #defines using
 BIT(foo)
Date: Fri, 07 Nov 2014 13:15:39 -0800
Message-ID: <1415394939.23530.20.camel@perches.com>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	 <1415265610-9338-10-git-send-email-jiri@resnulli.us>
	 <20141107.151607.480474516800359791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141107.151607.480474516800359791.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using BIT(foo) and BIT_ULL(bar) is more common now.
Suggest using these macros over #defines with 1<<value.

Add a --fix option too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 893cbd5..b5dc3f4 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4973,6 +4973,17 @@ sub process {
 			}
 		}
 
+# check for #defines like: 1 << <digit> that could be BIT(digit)
+		if ($line =~ /#\s*define\s+\w+\s+\(?\s*1\s*([ulUL]*)\s*\<\<\s*(?:\d+|$Ident)\s*\)?/) {
+			my $ull = "";
+			$ull = "_ULL" if (defined($1) && $1 =~ /ll/i);
+			if (CHK("BIT_MACRO",
+				"Prefer using the BIT$ull macro\n" . $herecurr) &&
+			    $fix) {
+				$fixed[$fixlinenr] =~ s/\(?\s*1\s*[ulUL]*\s*<<\s*(\d+|$Ident)\s*\)?/BIT${ull}($1)/;
+			}
+		}
+
 # check for case / default statements not preceded by break/fallthrough/switch
 		if ($line =~ /^.\s*(?:case\s+(?:$Ident|$Constant)\s*|default):/) {
 			my $has_break = 0;
