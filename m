From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH] Documentation: add documentation summary for rc-series and
	merge window
Date: Mon, 22 Jun 2009 14:04:38 -0400
Message-ID: <20090622180438.GG23972@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Greg KH <greg@kroah.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>,
	lrodriguez@atheros.com
To: torvalds@linux-foundation.org, Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52861 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbZFVSEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 14:04:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is losely based on previous discussions on linux-kernel [1][2][3].
Lets also refer people reading the stable rules to
Documentation/development-process/.

Also add the number of days it has taken between releases,
and provide the average for the last 10 releases: 86.0 days.

[1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
[2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2
[3] http://marc.info/?l=linux-kernel&m=124515657407679&w=2

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---

OK PATCH form now based on all the feedback.

 Documentation/development-process/2.Process |  121 ++++++++++++++++++++++++--
 Documentation/stable_kernel_rules.txt       |    5 +
 2 files changed, 116 insertions(+), 10 deletions(-)

diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
index d750321..41a05ed 100644
--- a/Documentation/development-process/2.Process
+++ b/Documentation/development-process/2.Process
@@ -7,20 +7,121 @@ course of one year, the kernel has since had to evolve a number of
 processes to keep development happening smoothly.  A solid understanding of
 how the process works is required in order to be an effective part of it.
 
+2.0:SUMMARY
+
+This section provides a brief summary of the kernel release rules.
+
+2.0.0: KERNEL RELEASE RULES
+
+Stable kernels are released when they are ready! This means there are
+absolutely no strict guidelines for sticking to specific dates for a
+kernel release.
+
+2.0.1: MERGE WINDOW
+
+The merge window opens up after the next stable kernel is released.
+The merge window is when maintainers of different subsystems send pull
+requests to Linus for code they have been queuing up for the next
+stable kernel. This is typically now done through respective
+foo-next-2.6.git trees where foo is your subsystem. Each maintainer
+queues up patches for the next kernel cycle in this foo-next-2.6.git
+tree. After the merge window the kernel is worked on through the
+rc-series of the kernel release. The merge window closes at the first
+rc-series release.
+
+After a maintainer has sent his pull request to Linus during the merge
+window no further new development will be accepted for that tree and
+as such it marks the closure of development for that subsystem for that
+kernel cycle.
+
+Developers wishing to target deadlines should simply work on their development
+without regards or consideration for inclusion to a specific kernel release.
+Once development is done it should simply be posted. If you insist on targeting
+a kernel release for deadlines you can try to be aware of the current rc cycle 
+development and how soon it seems the next stable kernel release will be made.
+
+A good indication of when the next stable kernel release will be made is when
+Linus notes the last rc cycle released may be the last. By this time you
+should already have all your development done and merged in the respective
+development tree. If your code is not ready and merged into the respective
+maintainers tree prior to the announced last potential rc kernel release
+chances are you missed getting your code in for the next kernel merge window.
+Exemptions here are new drivers, covered below.
+
+2.0.2: RC-SERIES RULES
+
+This section summarizes what kind of patches are accepted before the merge
+window closes and after it closes. These patches are targeted for the kernel
+prior to its final release.
+
+The rc-series focus should really be to address regressions.
+
+2.0.2.0: RC-SERIES RULES PRIOR TO THE RC1 RELEASE
+
+These are the types of patches that will get accepted prior to a kernel rc1 release,
+during the merge window:
+
+ - it must fix a regression
+ - it must fix a security hole
+ - it must fix a oops/kernel hang
+
+Non-intrusive bug fixes or small fixes will not be accepted. If the patch in
+question is for a driver that has been around for more than a kernel release,
+then "small fixes" really can't be worth all that much. And "small fixes" may
+be small and "obvious" they definitely can regress.
+
+When in doubt consult with your subsystem maintainer or just allow him to
+do the judging of where the patches deserves to go to, a proper commit log
+should help with this effort.
+
+2.0.2.1: RC-SERIES RULES AFTER THE RC1 RELEASE
+
+There are no more merges after the rc1 release.
+
+The same type of patches are accepted after the rc1 release with the addition
+of non-intrusive bug fix patches. Non-intrusive bug fixes must be important
+and address very clearly the bug they are fixing. Non-intrusive bug fixes
+can fix issues which are not a regression, security hole or a kernel oops/hang.
+
+Non-intrusive bug fix patches will not be accepted late in the rc-series, after
+the rc5, for example.
+
+You should not take it for granted non-intrusive bug fixes will always be accepted.
+Ultimately it is up to the subsystem maintainers to decide whether to accept such a fix
+or not, which is why your commit log entry is very important. You want to provide as
+much detail as is posisible in order to help maintainers make the right call.
+
+2.0.3 RC-SERIES NEW DRIVER EXEMPTION RULE
+
+The very first release a new driver or filesystem is special. New drivers
+are accepted during the rc series. Patches for the same driver then are
+also accepted during the same rc series of a kernel as well as fixes for it
+cannot regress as no previous kernels exists with it.
+
+Once drivers are upstream for one kernel release (say on 2.6.29) the target
+*goal* after the merge window of the next kernel (respectively this would be
+the 2.6.30 rc-series) is to address regressions. Kernel oops/hangs and security
+issues are obviously accepted but the point is these should have also been
+caught earlier as a general development goal.
 
 2.1: THE BIG PICTURE
 
 The kernel developers use a loosely time-based release process, with a new
-major kernel release happening every two or three months.  The recent
-release history looks like this:
-
-	2.6.26	July 13, 2008
-	2.6.25	April 16, 2008
-	2.6.24	January 24, 2008
-	2.6.23	October 9, 2007
-	2.6.22	July 8, 2007
-	2.6.21	April 25, 2007
-	2.6.20	February 4, 2007
+major kernel release happening about every two or three months. The current
+average time based on the last 10 releases is 86.0 days. The recent release
+history along with the number of days between each release looks like this:
+
+	2.6.30	June 10, 2009 - 78 days
+	2.6.29  March 23, 2009 - 89 days
+	2.6.28	December 29, 2008 - 76 days
+	2.6.27	October 8, 2008 - 88 days
+	2.6.26	July 13, 2008 - 88 days
+	2.6.25	April 16, 2008 - 83 days
+	2.6.24	January 24, 2008 - 108 days
+	2.6.23	October 9, 2007 - 94 days
+	2.6.22	July 8, 2007 - 75 days
+	2.6.21	April 25, 2007 - 81 days
+	2.6.20	February 4, 2007 - 68
 
 Every 2.6.x release is a major kernel release with new features, internal
 API changes, and more.  A typical 2.6 release can contain over 10,000
diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
index a452227..113e8c8 100644
--- a/Documentation/stable_kernel_rules.txt
+++ b/Documentation/stable_kernel_rules.txt
@@ -1,5 +1,10 @@
 Everything you ever wanted to know about Linux 2.6 -stable releases.
 
+For further details, such as stable kernel release schedules, rc-series
+policies and process of development please refer to:
+
+Documentation/development-process/
+
 Rules on what kind of patches are accepted, and which ones are not, into the
 "-stable" tree:
 
-- 
1.6.3.1

