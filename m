From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] checkpatch: Add some --strict coding style checks
Date: Tue, 21 Feb 2012 12:59:19 -0800
Message-ID: <1329857959.5143.11.camel@joe2Laptop>
References: <20120221151435.GA19354@tuxdriver.com>
	 <20120221.144417.1445117001833888214.davem@davemloft.net>
	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	 <20120221.154053.2103818562080068513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120221.154053.2103818562080068513.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Argument alignment across multiple lines should
match the open parenthesis.

Logical continuations should be at the end of
the previous line, not the start of a new line.

These are not required by CodingStyle so make the
tests active only when using --strict.

Tested with:
int foo(void)
{
	if (foo &&
	    bar())
		baz();

	if (foo &&
	     bar())
		baz();

	foo_some_long_function(bar,
			       baz);

	foo_some_long_function(bar,
		baz);

	return 0;
}

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 scripts/checkpatch.pl |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index a3b9782..629944e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -1783,6 +1783,28 @@ sub process {
 			     "please, no space before tabs\n" . $herevet);
 		}
 
+# check for && or || at the start of a line
+		if ($rawline =~ /^\+\s*(&&|\|\|)/) {
+			CHK("LOGICAL_CONTINUATIONS",
+			    "Logical continuations should be on the previous line\n" . $hereprev);
+		}
+
+# check multi-line statement indentation matches previous line
+		if ($prevline =~ /^\+(\t*)(if \(|$Ident\().*(\&\&|\|\||,)\s*$/ && $rawline =~ /^\+([ \t]*)/) {
+			$prevline =~ /^\+(\t*)(if \(|$Ident\().*(\&\&|\|\||,)\s*$/;
+			my $oldindent = $1;
+			my $if_or_func = $2;
+			$rawline =~ /^\+([ \t]*)/;
+			my $newindent = $1;
+			my $goodindent = $oldindent .
+					 "\t" x (length($if_or_func) / 8) .
+					 " "  x (length($if_or_func) % 8);
+			if ($newindent ne "$goodindent") {
+				CHK("PARENTHESIS_ALIGNMENT",
+				    "Alignment should match open parenthesis\n" . $hereprev);
+			}
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
