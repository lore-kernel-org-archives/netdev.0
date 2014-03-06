From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: net and drivers/net: Warn on missing blank line
 after variable declaration
Date: Thu, 06 Mar 2014 15:28:40 -0800
Message-ID: <1394148520.16156.8.camel@joe-AO722>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
	 <1394104390-23477-1-git-send-email-kys@microsoft.com>
	 <20140306.142919.763823800315842610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kys@microsoft.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, apw@canonical.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306.142919.763823800315842610.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Networking prefers this style, so warn when it's not used.

Networking uses:

void foo(int bar)
{
	int baz;

	code...
}

not

void foo(int bar)
{
	int baz;
	code...
}

There are a limited number of false positives when using
macros to declare variables like:

WARNING: networking uses a blank line after declarations
#330: FILE: net/ipv4/inet_hashtables.c:330:
+	int dif = sk->sk_bound_dev_if;
+	INET_ADDR_COOKIE(acookie, saddr, daddr)

Signed-off-by: Joe Perches <joe@perches.com>
---
 scripts/checkpatch.pl | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 3d3ef2f..a6e3048 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2248,6 +2248,21 @@ sub process {
 			     "networking block comments put the trailing */ on a separate line\n" . $herecurr);
 		}
 
+# check for missing blank lines after declarations
+		if ($realfile =~ m@^(drivers/net/|net/)@ &&
+		    $prevline =~ /^\+\s+$Declare\s+$Ident/ &&
+		    !($prevline =~ /(?:$Compare|$Assignment|$Operators)\s*$/ ||
+		      $prevline =~ /(?:\{\s*|\\)$/) &&		#extended lines
+		    $sline =~ /^\+\s+/ &&			#Not at char 1
+		    !($sline =~ /^\+\s+$Declare/ ||
+		      $sline =~ /^\+\s+$Ident\s+$Ident/ ||	#eg: typedef foo
+		      $sline =~ /^\+\s+(?:union|struct|enum|typedef)\b/ ||
+		      $sline =~ /^\+\s+(?:$|[\{\}\.\#\"\?\:\(])/ ||
+		      $sline =~ /^\+\s+\(?\s*(?:$Compare|$Assignment|$Operators)/)) {
+			WARN("SPACING",
+			     "networking uses a blank line after declarations\n" . $hereprev);
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
