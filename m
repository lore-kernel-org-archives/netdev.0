From: Joe Perches <joe@perches.com>
Subject: Coding Style: Reverse XMAS tree declarations ? (was Re: [PATCH
 net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet)
Date: Thu, 03 Nov 2016 23:53:58 -0700
Message-ID: <1478242438.1924.31.camel@perches.com>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
         <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
         <20161103.155816.642712588084106823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xjdSJgU+LAqKYDxFD8PF"
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: David Miller <davem@davemloft.net>, madalin.bucur@nxp.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103.155816.642712588084106823.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xjdSJgU+LAqKYDxFD8PF
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit

On Thu, 2016-11-03 at 15:58 -0400, David Miller wrote:
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Wed, 2 Nov 2016 22:17:26 +0200
> 
> > This introduces the Freescale Data Path Acceleration Architecture
> > +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
> > +{
> > +     u8 i;
> > +     size_t res = DPAA_BP_RAW_SIZE / 2;
> 
> Always order local variable declarations from longest to shortest line,
> also know as Reverse Christmas Tree Format.

I think this declaration sorting order is misguided but
here's a possible change to checkpatch adding a test for it
that does this test just for net/ and drivers/net/

(this likely won't apply because Evolution is a horrible
email client for sending patches, but the attachment should)

An example output:

$ ./scripts/checkpatch.pl -f drivers/net/ethernet/ethoc.c --types=reverse_xmas_tree --show-types
CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#200: FILE: drivers/net/ethernet/ethoc.c:200:
+	void __iomem *iobase;
+	void __iomem *membase;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#202: FILE: drivers/net/ethernet/ethoc.c:202:
+	int dma_alloc;
+	resource_size_t io_region_size;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#305: FILE: drivers/net/ethernet/ethoc.c:305:
+	int i;
+	void *vma;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#446: FILE: drivers/net/ethernet/ethoc.c:446:
+			int size = bd.stat >> 16;
+			struct sk_buff *skb;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#515: FILE: drivers/net/ethernet/ethoc.c:515:
+	int count;
+	struct ethoc_bd bd;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#675: FILE: drivers/net/ethernet/ethoc.c:675:
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phy;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#756: FILE: drivers/net/ethernet/ethoc.c:756:
+	struct ethoc *priv = netdev_priv(dev);
+	struct mii_ioctl_data *mdio = if_mii(ifr);

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#801: FILE: drivers/net/ethernet/ethoc.c:801:
+	u32 mode = ethoc_read(priv, MODER);
+	struct netdev_hw_addr *ha;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#996: FILE: drivers/net/ethernet/ethoc.c:996:
+	struct resource *res = NULL;
+	struct resource *mmio = NULL;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#1001: FILE: drivers/net/ethernet/ethoc.c:1001:
+	int ret = 0;
+	bool random_mac = false;

CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to shortest
#1002: FILE: drivers/net/ethernet/ethoc.c:1002:
+	bool random_mac = false;
+	struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);

total: 0 errors, 0 warnings, 11 checks, 1297 lines checked

NOTE: For some of the reported defects, checkpatch may be able to
      mechanically convert to the typical style using --fix or --fix-inplace.

drivers/net/ethernet/ethoc.c has style problems, please review.

NOTE: Used message types: REVERSE_XMAS_TREE

NOTE: If any of the errors are false positives, please report
      them to the maintainer, see CHECKPATCH in MAINTAINERS.
---
 scripts/checkpatch.pl | 70 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 56 insertions(+), 14 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index fdacd759078e..dd344ac77cb8 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2114,6 +2114,29 @@ sub pos_last_openparen {
 	return length(expand_tabs(substr($line, 0, $last_openparen))) + 1;
 }
 
+sub get_decl {
+	my ($line) = @_;
+
+	# typical declarations
+	if ($line =~ /^\+\s+($Declare\s*$Ident)\s*[=,;:\[]/) {
+		return $1;
+	}
+	# function pointer declarations
+	if ($line =~ /^\+\s+($Declare\s*\(\s*\*\s*$Ident\s*\))\s*[=,;:\[\(]/) {
+		return $1;
+	}
+	# foo bar; where foo is some local typedef or #define
+	if ($line =~ /^\+\s+($Ident(?:\s+|\s*\*\s*)$Ident)\s*[=,;\[]/) {
+		return $1;
+	}
+	# known declaration macros
+	if ($line =~ /^\+\s+$(declaration_macros)/) {
+		return $1;
+	}
+
+	return undef;
+}
+
 sub process {
 	my $filename = shift;
 
@@ -3063,9 +3086,7 @@ sub process {
 			$last_blank_line = $linenr;
 		}
 
-# check for missing blank lines after declarations
-		if ($sline =~ /^\+\s+\S/ &&			#Not at char 1
-			# actual declarations
+		my $prev_decl =
 		    ($prevline =~ /^\+\s+$Declare\s*$Ident\s*[=,;:\[]/ ||
 			# function pointer declarations
 		     $prevline =~ /^\+\s+$Declare\s*\(\s*\*\s*$Ident\s*\)\s*[=,;:\[\(]/ ||
@@ -3078,25 +3099,30 @@ sub process {
 			# other possible extensions of declaration lines
 		      $prevline =~ /(?:$Compare|$Assignment|$Operators)\s*$/ ||
 			# not starting a section or a macro "\" extended line
-		      $prevline =~ /(?:\{\s*|\\)$/) &&
-			# looks like a declaration
-		    !($sline =~ /^\+\s+$Declare\s*$Ident\s*[=,;:\[]/ ||
+		      $prevline =~ /(?:\{\s*|\\)$/);
+		my $sline_decl =
+		    $sline =~ /^\+\s+$Declare\s*$Ident\s*[=,;:\[]/ ||
 			# function pointer declarations
-		      $sline =~ /^\+\s+$Declare\s*\(\s*\*\s*$Ident\s*\)\s*[=,;:\[\(]/ ||
+		    $sline =~ /^\+\s+$Declare\s*\(\s*\*\s*$Ident\s*\)\s*[=,;:\[\(]/ ||
 			# foo bar; where foo is some local typedef or #define
-		      $sline =~ /^\+\s+$Ident(?:\s+|\s*\*\s*)$Ident\s*[=,;\[]/ ||
+		    $sline =~ /^\+\s+$Ident(?:\s+|\s*\*\s*)$Ident\s*[=,;\[]/ ||
 			# known declaration macros
-		      $sline =~ /^\+\s+$declaration_macros/ ||
+		    $sline =~ /^\+\s+$declaration_macros/ ||
 			# start of struct or union or enum
-		      $sline =~ /^\+\s+(?:union|struct|enum|typedef)\b/ ||
+		    $sline =~ /^\+\s+(?:union|struct|enum|typedef)\b/ ||
 			# start or end of block or continuation of declaration
-		      $sline =~ /^\+\s+(?:$|[\{\}\.\#\"\?\:\(\[])/ ||
+		    $sline =~ /^\+\s+(?:$|[\{\}\.\#\"\?\:\(\[])/ ||
 			# bitfield continuation
-		      $sline =~ /^\+\s+$Ident\s*:\s*\d+\s*[,;]/ ||
+		    $sline =~ /^\+\s+$Ident\s*:\s*\d+\s*[,;]/ ||
 			# other possible extensions of declaration lines
-		      $sline =~ /^\+\s+\(?\s*(?:$Compare|$Assignment|$Operators)/) &&
+		    $sline =~ /^\+\s+\(?\s*(?:$Compare|$Assignment|$Operators)/;
+
+# check for missing blank lines after declarations
+		if ($sline =~ /^\+\s+\S/ &&			#Not at char 1
+			# actual declarations
+		    $prev_decl && !$sline_decl &&
 			# indentation of previous and current line are the same
-		    (($prevline =~ /\+(\s+)\S/) && $sline =~ /^\+$1\S/)) {
+		    ($prevline =~ /\+(\s+)\S/ && $sline =~ /^\+$1\S/)) {
 			if (WARN("LINE_SPACING",
 				 "Missing a blank line after declarations\n" . $hereprev) &&
 			    $fix) {
@@ -3104,6 +3130,22 @@ sub process {
 			}
 		}
 
+# check for reverse christmas tree declarations in net/ and drivers/net/
+		if ($realfile =~ m@^(?:drivers/net/|net/)@ &&
+		    $sline =~ /^\+\s+\S/ &&			#Not at char 1
+			# actual declarations
+		    $prev_decl && $sline_decl &&
+			# indentation of previous and current line are the same
+		    (($prevline =~ /\+(\s+)\S/) && $sline =~ /^\+$1\S/)) {
+			my $p = get_decl($prevline);
+			my $l = get_decl($sline);
+			if (defined($p) && defined($l) && length($p) < length($l) &&
+			    CHK("REVERSE_XMAS_TREE",
+				"Prefer ordering declarations longest to shortest\n" . $hereprev) &&
+			    $fix) {
+			}
+		}
+
 # check for spaces at the beginning of a line.
 # Exceptions:
 #  1) within comments
--=-xjdSJgU+LAqKYDxFD8PF
Content-Disposition: attachment; filename="cp_xmas.diff"
Content-Type: text/x-patch; name="cp_xmas.diff"; charset="ISO-8859-1"
Content-Transfer-Encoding: base64

IHNjcmlwdHMvY2hlY2twYXRjaC5wbCB8IDcwICsrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKystLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDU2IGluc2VydGlvbnMoKyks
IDE0IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL3NjcmlwdHMvY2hlY2twYXRjaC5wbCBiL3Nj
cmlwdHMvY2hlY2twYXRjaC5wbAppbmRleCBmZGFjZDc1OTA3OGUuLmRkMzQ0YWM3N2NiOCAxMDA3
NTUKLS0tIGEvc2NyaXB0cy9jaGVja3BhdGNoLnBsCisrKyBiL3NjcmlwdHMvY2hlY2twYXRjaC5w
bApAQCAtMjExNCw2ICsyMTE0LDI5IEBAIHN1YiBwb3NfbGFzdF9vcGVucGFyZW4gewogCXJldHVy
biBsZW5ndGgoZXhwYW5kX3RhYnMoc3Vic3RyKCRsaW5lLCAwLCAkbGFzdF9vcGVucGFyZW4pKSkg
KyAxOwogfQogCitzdWIgZ2V0X2RlY2wgeworCW15ICgkbGluZSkgPSBAXzsKKworCSMgdHlwaWNh
bCBkZWNsYXJhdGlvbnMKKwlpZiAoJGxpbmUgPX4gL15cK1xzKygkRGVjbGFyZVxzKiRJZGVudClc
cypbPSw7OlxbXS8pIHsKKwkJcmV0dXJuICQxOworCX0KKwkjIGZ1bmN0aW9uIHBvaW50ZXIgZGVj
bGFyYXRpb25zCisJaWYgKCRsaW5lID1+IC9eXCtccysoJERlY2xhcmVccypcKFxzKlwqXHMqJElk
ZW50XHMqXCkpXHMqWz0sOzpcW1woXS8pIHsKKwkJcmV0dXJuICQxOworCX0KKwkjIGZvbyBiYXI7
IHdoZXJlIGZvbyBpcyBzb21lIGxvY2FsIHR5cGVkZWYgb3IgI2RlZmluZQorCWlmICgkbGluZSA9
fiAvXlwrXHMrKCRJZGVudCg/OlxzK3xccypcKlxzKikkSWRlbnQpXHMqWz0sO1xbXS8pIHsKKwkJ
cmV0dXJuICQxOworCX0KKwkjIGtub3duIGRlY2xhcmF0aW9uIG1hY3JvcworCWlmICgkbGluZSA9
fiAvXlwrXHMrJChkZWNsYXJhdGlvbl9tYWNyb3MpLykgeworCQlyZXR1cm4gJDE7CisJfQorCisJ
cmV0dXJuIHVuZGVmOworfQorCiBzdWIgcHJvY2VzcyB7CiAJbXkgJGZpbGVuYW1lID0gc2hpZnQ7
CiAKQEAgLTMwNjMsOSArMzA4Niw3IEBAIHN1YiBwcm9jZXNzIHsKIAkJCSRsYXN0X2JsYW5rX2xp
bmUgPSAkbGluZW5yOwogCQl9CiAKLSMgY2hlY2sgZm9yIG1pc3NpbmcgYmxhbmsgbGluZXMgYWZ0
ZXIgZGVjbGFyYXRpb25zCi0JCWlmICgkc2xpbmUgPX4gL15cK1xzK1xTLyAmJgkJCSNOb3QgYXQg
Y2hhciAxCi0JCQkjIGFjdHVhbCBkZWNsYXJhdGlvbnMKKwkJbXkgJHByZXZfZGVjbCA9CiAJCSAg
ICAoJHByZXZsaW5lID1+IC9eXCtccyskRGVjbGFyZVxzKiRJZGVudFxzKls9LDs6XFtdLyB8fAog
CQkJIyBmdW5jdGlvbiBwb2ludGVyIGRlY2xhcmF0aW9ucwogCQkgICAgICRwcmV2bGluZSA9fiAv
XlwrXHMrJERlY2xhcmVccypcKFxzKlwqXHMqJElkZW50XHMqXClccypbPSw7OlxbXChdLyB8fApA
QCAtMzA3OCwyNSArMzA5OSwzMCBAQCBzdWIgcHJvY2VzcyB7CiAJCQkjIG90aGVyIHBvc3NpYmxl
IGV4dGVuc2lvbnMgb2YgZGVjbGFyYXRpb24gbGluZXMKIAkJICAgICAgJHByZXZsaW5lID1+IC8o
PzokQ29tcGFyZXwkQXNzaWdubWVudHwkT3BlcmF0b3JzKVxzKiQvIHx8CiAJCQkjIG5vdCBzdGFy
dGluZyBhIHNlY3Rpb24gb3IgYSBtYWNybyAiXCIgZXh0ZW5kZWQgbGluZQotCQkgICAgICAkcHJl
dmxpbmUgPX4gLyg/Olx7XHMqfFxcKSQvKSAmJgotCQkJIyBsb29rcyBsaWtlIGEgZGVjbGFyYXRp
b24KLQkJICAgICEoJHNsaW5lID1+IC9eXCtccyskRGVjbGFyZVxzKiRJZGVudFxzKls9LDs6XFtd
LyB8fAorCQkgICAgICAkcHJldmxpbmUgPX4gLyg/Olx7XHMqfFxcKSQvKTsKKwkJbXkgJHNsaW5l
X2RlY2wgPQorCQkgICAgJHNsaW5lID1+IC9eXCtccyskRGVjbGFyZVxzKiRJZGVudFxzKls9LDs6
XFtdLyB8fAogCQkJIyBmdW5jdGlvbiBwb2ludGVyIGRlY2xhcmF0aW9ucwotCQkgICAgICAkc2xp
bmUgPX4gL15cK1xzKyREZWNsYXJlXHMqXChccypcKlxzKiRJZGVudFxzKlwpXHMqWz0sOzpcW1wo
XS8gfHwKKwkJICAgICRzbGluZSA9fiAvXlwrXHMrJERlY2xhcmVccypcKFxzKlwqXHMqJElkZW50
XHMqXClccypbPSw7OlxbXChdLyB8fAogCQkJIyBmb28gYmFyOyB3aGVyZSBmb28gaXMgc29tZSBs
b2NhbCB0eXBlZGVmIG9yICNkZWZpbmUKLQkJICAgICAgJHNsaW5lID1+IC9eXCtccyskSWRlbnQo
Pzpccyt8XHMqXCpccyopJElkZW50XHMqWz0sO1xbXS8gfHwKKwkJICAgICRzbGluZSA9fiAvXlwr
XHMrJElkZW50KD86XHMrfFxzKlwqXHMqKSRJZGVudFxzKls9LDtcW10vIHx8CiAJCQkjIGtub3du
IGRlY2xhcmF0aW9uIG1hY3JvcwotCQkgICAgICAkc2xpbmUgPX4gL15cK1xzKyRkZWNsYXJhdGlv
bl9tYWNyb3MvIHx8CisJCSAgICAkc2xpbmUgPX4gL15cK1xzKyRkZWNsYXJhdGlvbl9tYWNyb3Mv
IHx8CiAJCQkjIHN0YXJ0IG9mIHN0cnVjdCBvciB1bmlvbiBvciBlbnVtCi0JCSAgICAgICRzbGlu
ZSA9fiAvXlwrXHMrKD86dW5pb258c3RydWN0fGVudW18dHlwZWRlZilcYi8gfHwKKwkJICAgICRz
bGluZSA9fiAvXlwrXHMrKD86dW5pb258c3RydWN0fGVudW18dHlwZWRlZilcYi8gfHwKIAkJCSMg
c3RhcnQgb3IgZW5kIG9mIGJsb2NrIG9yIGNvbnRpbnVhdGlvbiBvZiBkZWNsYXJhdGlvbgotCQkg
ICAgICAkc2xpbmUgPX4gL15cK1xzKyg/OiR8W1x7XH1cLlwjXCJcP1w6XChcW10pLyB8fAorCQkg
ICAgJHNsaW5lID1+IC9eXCtccysoPzokfFtce1x9XC5cI1wiXD9cOlwoXFtdKS8gfHwKIAkJCSMg
Yml0ZmllbGQgY29udGludWF0aW9uCi0JCSAgICAgICRzbGluZSA9fiAvXlwrXHMrJElkZW50XHMq
OlxzKlxkK1xzKlssO10vIHx8CisJCSAgICAkc2xpbmUgPX4gL15cK1xzKyRJZGVudFxzKjpccypc
ZCtccypbLDtdLyB8fAogCQkJIyBvdGhlciBwb3NzaWJsZSBleHRlbnNpb25zIG9mIGRlY2xhcmF0
aW9uIGxpbmVzCi0JCSAgICAgICRzbGluZSA9fiAvXlwrXHMrXCg/XHMqKD86JENvbXBhcmV8JEFz
c2lnbm1lbnR8JE9wZXJhdG9ycykvKSAmJgorCQkgICAgJHNsaW5lID1+IC9eXCtccytcKD9ccyoo
PzokQ29tcGFyZXwkQXNzaWdubWVudHwkT3BlcmF0b3JzKS87CisKKyMgY2hlY2sgZm9yIG1pc3Np
bmcgYmxhbmsgbGluZXMgYWZ0ZXIgZGVjbGFyYXRpb25zCisJCWlmICgkc2xpbmUgPX4gL15cK1xz
K1xTLyAmJgkJCSNOb3QgYXQgY2hhciAxCisJCQkjIGFjdHVhbCBkZWNsYXJhdGlvbnMKKwkJICAg
ICRwcmV2X2RlY2wgJiYgISRzbGluZV9kZWNsICYmCiAJCQkjIGluZGVudGF0aW9uIG9mIHByZXZp
b3VzIGFuZCBjdXJyZW50IGxpbmUgYXJlIHRoZSBzYW1lCi0JCSAgICAoKCRwcmV2bGluZSA9fiAv
XCsoXHMrKVxTLykgJiYgJHNsaW5lID1+IC9eXCskMVxTLykpIHsKKwkJICAgICgkcHJldmxpbmUg
PX4gL1wrKFxzKylcUy8gJiYgJHNsaW5lID1+IC9eXCskMVxTLykpIHsKIAkJCWlmIChXQVJOKCJM
SU5FX1NQQUNJTkciLAogCQkJCSAiTWlzc2luZyBhIGJsYW5rIGxpbmUgYWZ0ZXIgZGVjbGFyYXRp
b25zXG4iIC4gJGhlcmVwcmV2KSAmJgogCQkJICAgICRmaXgpIHsKQEAgLTMxMDQsNiArMzEzMCwy
MiBAQCBzdWIgcHJvY2VzcyB7CiAJCQl9CiAJCX0KIAorIyBjaGVjayBmb3IgcmV2ZXJzZSBjaHJp
c3RtYXMgdHJlZSBkZWNsYXJhdGlvbnMgaW4gbmV0LyBhbmQgZHJpdmVycy9uZXQvCisJCWlmICgk
cmVhbGZpbGUgPX4gbUBeKD86ZHJpdmVycy9uZXQvfG5ldC8pQCAmJgorCQkgICAgJHNsaW5lID1+
IC9eXCtccytcUy8gJiYJCQkjTm90IGF0IGNoYXIgMQorCQkJIyBhY3R1YWwgZGVjbGFyYXRpb25z
CisJCSAgICAkcHJldl9kZWNsICYmICRzbGluZV9kZWNsICYmCisJCQkjIGluZGVudGF0aW9uIG9m
IHByZXZpb3VzIGFuZCBjdXJyZW50IGxpbmUgYXJlIHRoZSBzYW1lCisJCSAgICAoKCRwcmV2bGlu
ZSA9fiAvXCsoXHMrKVxTLykgJiYgJHNsaW5lID1+IC9eXCskMVxTLykpIHsKKwkJCW15ICRwID0g
Z2V0X2RlY2woJHByZXZsaW5lKTsKKwkJCW15ICRsID0gZ2V0X2RlY2woJHNsaW5lKTsKKwkJCWlm
IChkZWZpbmVkKCRwKSAmJiBkZWZpbmVkKCRsKSAmJiBsZW5ndGgoJHApIDwgbGVuZ3RoKCRsKSAm
JgorCQkJICAgIENISygiUkVWRVJTRV9YTUFTX1RSRUUiLAorCQkJCSJQcmVmZXIgb3JkZXJpbmcg
ZGVjbGFyYXRpb25zIGxvbmdlc3QgdG8gc2hvcnRlc3RcbiIgLiAkaGVyZXByZXYpICYmCisJCQkg
ICAgJGZpeCkgeworCQkJfQorCQl9CisKICMgY2hlY2sgZm9yIHNwYWNlcyBhdCB0aGUgYmVnaW5u
aW5nIG9mIGEgbGluZS4KICMgRXhjZXB0aW9uczoKICMgIDEpIHdpdGhpbiBjb21tZW50cwo=


--=-xjdSJgU+LAqKYDxFD8PF--
