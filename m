From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH v3.1415] Documentation: add documentation summary for
	rc-series and merge window
Date: Mon, 22 Jun 2009 18:22:17 -0400
Message-ID: <20090622222217.GH23972@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Greg KH <greg@kroah.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56772 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbZFVWWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 18:22:18 -0400
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
 Documentation/development-process/2.Process |  158 +++++++++++++++++++++++++--
 Documentation/stable_kernel_rules.txt       |    5 +
 2 files changed, 153 insertions(+), 10 deletions(-)

diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
index d750321..d4ca05d 100644
--- a/Documentation/development-process/2.Process
+++ b/Documentation/development-process/2.Process
@@ -7,20 +7,158 @@ course of one year, the kernel has since had to evolve a number of
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
+2.0.1: PATCH QUEUING FOR THE NEXT KERNEL RELEASE
+
+Linus maintains the development kernel, this means he accepts new
+features and drivers for the next kernel release. He however does not
+maintain every single line of the kernel. The kernel is broken down by
+different subsystems and each subsystem has its own maintainer. In order
+to aid the development of Linux maintainers subsystem have trees where
+they queue patches for the next kernel release. This is typically done
+with a foo-next-2.6.git tree where foo would be an arbitrary subsystem
+name. These trees typically are designed to have a clean git history
+to make pulling for Linus easier and as clean as possible.
+
+Subsystem maintainers can typically have their own development git trees
+apart from the foo-next-2.6.git trees as a breeding ground and test ground
+for bleeding edge patches. Subsystem maintainers are at complete freedom to
+maintain these trees however they see fit. Once patches have been proven
+stable enough in a development tree they tend to be moved to their
+respective foo-next-2.6.git tree.
+
+Subsystem development trees are *always* open for development and new patches
+are always accepted. After a new kernel is released subsystem maintainers
+tend to slow down in accepting patches into their development trees though
+so that the new development can eventually be rebased easily ontop of the
+next kernel rc1 release.
+
+If your patch is adding a new feature or changing a lot of code and you send
+it between a stable kernel release and prior to the rc1 kernel release it will
+likely be a while before it is merged into a development tree, so be patient
+during this time.
+
+2.0.1: MERGE WINDOW
+
+The merge window opens up after the next stable kernel is released and takes
+two weeks. The merge window is when maintainers of different subsystems send
+pull requests to Linus for code they have been queuing up for the next stable
+kernel. These are the foo-next-2.6.git trees.
+
+After the merge window the kernel is worked on through the rc-series of the
+kernel release. The rc-series focus is to address regressions. The merge window
+closes upon the first rc-series release, rc1.
+
+After a subsystem maintainer has sent his pull request to Linus during the merge
+window no further new development will be accepted for that foo-next-2.6.git
+tree and as such it marks the closure of development for that subsystem for that
+kernel cycle.
+
+2.0.2: MEETING DEADLINES FOR KERNEL RELEASES
+
+Developers wishing to target deadlines should simply work on their development
+without regards or consideration for inclusion to a specific kernel release.
+Once development is done it should simply be posted so the community can review it
+and it can eventually be merged into the appropriate development subsystem tree.
+
+If you insist on targeting a kernel release for deadlines you can try to be aware
+of the current rc cycle development and how soon it seems the next stable kernel
+release will be made.
+
+A good indication of when the next stable kernel release will be made is when
+Linus notes the last rc cycle released may be the last. By this time you
+should already have all your development done and merged in the respective
+development tree. If your code is not ready and merged into the respective
+maintainers development tree prior to the announced last potential rc kernel
+release chances are you missed getting your code in for the next kernel merge
+window. Exemptions here are new drivers, covered below.
+
+2.0.3: RC-SERIES RULES
+
+This section summarizes what kind of patches are accepted after a new stable kernel is
+released, before the merge window closes and after it closes. These patches are targeted
+for the kernel prior to its final release.
+
+2.0.3.0: RC-SERIES RULES PRIOR TO THE RC1 RELEASE
+
+Before the merge window closes, prior to the rc1 release, Linus accepts pull requests
+from different subsystem maintainers, with it go all the queued up material for the
+next kernel release for each respective subsystem, on all foo-next-2.6.git trees.
+After subsystem maintainers have sent their pull requests there are strict rules
+for new patches prior to the close of the merge window, marked by the rc1 release:
+
+ - patches must fix a regression
+ - patches must fix a security hole
+ - patches must fix a oops/kernel hang
+
+Non-intrusive bug fixes fixes will very likely not be accepted. Some maintainers
+may choose to accept some non-intrusive patches, depending on their work load.
+You should however not take it for granted such patches will get accepted. You
+should always just target the development kernel and provide a good commit to
+help with review.
+
+When in doubt consult with your subsystem maintainer or just allow him to
+do the judging of where the patches deserves to go to, an excellent commit log
+should help with this effort.
+
+2.0.3.1: RC-SERIES RULES AFTER THE RC1 RELEASE
+
+Linus does not accept more pull requests from subsystem maintainers after the
+rc1 release. This means you can expect no new features or new development after
+rc1.
+
+The same type of patches are accepted after the rc1 release with the addition
+of a slight warmer welcome for non-intrusive bug fix patches. Non-intrusive
+bug fixes must be important and address very clearly the bug they are fixing.
+Non-intrusive bug fixes can fix issues which are not a regression, security
+hole or a kernel oops/hang.
+
+Linus will not accept non-intrusive bug fix patches late in the rc-series, after
+the rc5, for example.
+
+You should never take it for granted non-intrusive bug fixes will be accepted.
+Ultimately it is up to the subsystem maintainers to decide whether to accept
+such a fix or not, which is why your commit log entry is critically important.
+You want to provide as much detail as is posisible in order to help maintainers
+make the right call.
+
+2.0.4 RC-SERIES NEW DRIVER EXEMPTION RULE
+
+The very first release a new driver or filesystem is special. New drivers
+are accepted during the rc-series! Patches for the same driver then are
+also accepted during the same rc-series of a kernel as well as fixes for it
+cannot regress as no previous kernels exists with it.
+
+After a driver has been present for one kernel release the relaxed rules for
+it during the rc-series are no longer applicable.
 
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

