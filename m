From: Joe Perches <joe@perches.com>
Subject: Re: [trivial PATCH] treewide: Fix printks with 0x%#
Date: Mon, 26 Aug 2013 23:00:47 -0700
Message-ID: <1377583247.2658.13.camel@joe-AO722>
References: <1374778405.1957.21.camel@joe-AO722>
	 <201308270139.29838.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <trivial@kernel.org>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	Helge Deller <deller@gmx.de>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Daniele Venzano <venza@brownhat.org>,
	Andi Kleen <andi@firstfloor.org>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	alsa-devel <alsa-devel@alsa-project.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <201308270139.29838.vapier@gentoo.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-27 at 01:39 -0400, Mike Frysinger wrote:
> On Thursday 25 July 2013 14:53:25 Joe Perches wrote:
> > Using 0x%# emits 0x0x.  Only one is necessary.
> 
> sounds like a job for checkpatch.pl :)

Here.  Submit it yourself...
---
 scripts/checkpatch.pl | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 9ba4fc4..520f8e7 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3869,6 +3869,18 @@ sub process {
 			}
 		}
 
+# check for formats with "0x%#"
+		if ($line =~ /"X*"/) {
+			my $fmt = get_quoted_string($line, $rawline);
+			if ($fmt =~ /0x%#/) {
+				if (WARN("REDUNDANT_HEX",
+					 "Redundant hex prefix 0x format\n" . $herecurr) &&
+				    $fix) {
+					$fixed[$linenr - 1] =~ s/0x%#/%#/g;
+				}
+			}
+		}
+
 # Check for misused memsets
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&



