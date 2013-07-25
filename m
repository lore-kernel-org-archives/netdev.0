From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Warn when using extern with function prototypes
 in .h files
Date: Wed, 24 Jul 2013 19:59:10 -0700
Message-ID: <1374721150.1924.26.camel@joe-AO722>
References: <1374602291.3387.17.camel@joe-AO722>
	 <kspuuk$k2v$1@ger.gmane.org> <1374716480.1924.18.camel@joe-AO722>
	 <20130725014732.GA10036@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36251 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752668Ab3GYC7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 22:59:12 -0400
In-Reply-To: <20130725014732.GA10036@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the extern keyword on function prototypes is superfluous
visual noise so suggest removing it.

Using extern can cause unnecessary line wrapping at 80 columns
and unnecessarily long multi-line function prototypes.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 2013-07-25 at 03:47 +0200, Hannes Frederic Sowa wrote:
> On Wed, Jul 24, 2013 at 06:41:20PM -0700, Joe Perches wrote:
> > On Thu, 2013-07-25 at 01:27 +0000, Cong Wang wrote:
> > > On Tue, 23 Jul 2013 at 17:58 GMT, Joe Perches <joe@perches.com> wrote:
> > > > Function prototypes don't need to be declared
> > > > extern in .h files.  It's assumed by the compiler
> > > > and is as unnecessary as using auto is when
> > > > declaring automatic/local variables in a block.
> > > Since we all know this, why bother it?
> > If everyone knew this, new ones wouldn't be added.
> > But a lot are.
> Couldn't checkpatch take care of these?

checkpatch doesn't work well for multiple lines so
this doesn't work on things like
	extern unsigned long
	foo(type bar);
but it does for the single line function prototypes.

Using --fix removes them.

 scripts/checkpatch.pl | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 6918517..23126d4 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3866,6 +3866,16 @@ sub process {
 			}
 		}
 
+# check for new externs in .h files.
+		if ($realfile =~ /\.h$/ &&
+		    $line =~ /^\+\s*(extern\s+)$Type\s*$Ident\s*\(/s) {
+			if (WARN("AVOID_EXTERNS",
+				 "extern prototypes should be avoided in .h files\n" . $herecurr) &&
+			    $fix) {
+				$fixed[$linenr - 1] =~ s/(.*)\bextern\b\s*(.*)/$1$2/;
+			}
+		}
+
 # check for new externs in .c files.
 		if ($realfile =~ /\.c$/ && defined $stat &&
 		    $stat =~ /^.\s*(?:extern\s+)?$Type\s+($Ident)(\s*)\(/s)
-- 
1.8.1.2.459.gbcd45b4.dirty
