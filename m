From: "Luis R. Rodriguez" <mcgrof@bombadil.infradead.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Mon, 15 Jun 2009 17:47:35 -0400
Message-ID: <20090615214735.GE23972@bombadil.infradead.org>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com> <20090615201934.GA12685@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tshibata@ab.jp.nec.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:59182 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935118AbZFOVrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 17:47:35 -0400
Content-Disposition: inline
In-Reply-To: <20090615201934.GA12685@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 01:19:34PM -0700, Greg KH wrote:
> On Mon, Jun 15, 2009 at 04:12:51PM -0400, Luis R. Rodriguez wrote:
> > This is losely based on previous discussions on linux-kernel [1][2].
> > 
> > [1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
> > [2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2
> > 
> > Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
> > ---
> > 
> > I have run into issues when trying to explain this and policies
> > for the rc-series, it seems there is no place that documents this
> > clearly so here is an attempt based on some previous discussions.
> > Not sure if I got it all correct, so feedback is welcomed. I do think
> > clarifying this a little should help.
> > 
> > I was also not sure if Documentation/stable_kernel_rules.txt is the best
> > splace for this as well, please let me know.
> 
> I don't think this is the best place for it, as the stable_* file is for
> describing the rules for the 2.6.x.y releases, not the main 2.6.x
> releases.
> 
> A new file perhaps?  Or an addition to the
> Documentation/development-process/ book?

OK here is that, with Pavel's changes taken into consideration.

From: Luis R. Rodriguez <lrodriguez@atheros.com>
Subject: [PATCH] Documentation: add documentation summary for rc-series and merge window

This is losely based on previous discussions on linux-kernel [1][2].
Lets also refer people reading the stable rules to
Documentation/development-process/.

[1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
[2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 Documentation/development-process/2.Process |   66 +++++++++++++++++++++++++++
 Documentation/stable_kernel_rules.txt       |    5 ++
 2 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
index d750321..e023db6 100644
--- a/Documentation/development-process/2.Process
+++ b/Documentation/development-process/2.Process
@@ -7,6 +7,72 @@ course of one year, the kernel has since had to evolve a number of
 processes to keep development happening smoothly.  A solid understanding of
 how the process works is required in order to be an effective part of it.
 
+2.0 SUMMARY
+
+This section provides a brief summary of the new kernel release rules.
+
+2.0.0 NEW KERNEL RELEASE RULES
+
+Stable kernels are released when they are ready! This means there are
+absolutely no strict guidelines for sticking to specific dates for a
+kernel release.
+
+2.0.1 MERGE WINDOW
+
+The merge window opens up after the next stable kernel is released.
+The merge window is when maintainers of different subsystem send pull
+requests to Linus for code they have been queuing up for the next
+stable kernel. This is typically now done through respective
+foo-next-2.6.git trees where foo is your subsystem. Each maintainer
+queues up patches for the next kernel cycle in this foo-next-2.6.git
+tree. After the merge window the kernel is worked on through the
+rc-series of the kernel release.
+
+After a maintainer has sent his pull request to Linus during the merge
+window no further new development will be accepted for that tree and
+as such it marks the closure of development for that subsystem for that
+kernel cycle. Developers wishing to target deadlines should simply work
+on their development without regards or consideration for inclusion to
+a specific kernel release. Once development is done it should simply be
+posted. If you insist on targeting a kernel release for deadlines you can
+try to be aware of the current rc cycle development and how soon it seems
+the next stable kernel release will be made. When Linus notes the last rc
+cycle released may be the last -- that is a good sign you should already
+have all your development done and merged in the respective development
+tree. If your code is not ready and merged into the respective maintainers
+tree prior to the announced last potential rc kernel release chances are
+you missed getting your code in for the next kernel merge window.
+Exemptions here are new drivers, covered below.
+
+2.0.2 RC-SERIES RULES
+
+Rules on what kind of patches are accepted after the merge window closes.
+These are patches targeted for the kernel rc-series of a kernel prior
+to its release.
+
+ - it must fix a reported regression
+ - if must fix a reported security hole
+ - if must fix a reported oops/kernel hang
+
+This means any small-non-fix code changes, although they might fix an issue,
+will not be accepted. If the patch in question is for a driver that has been
+around for more than a kernel release, then "small fixes" really can't be
+worth all that much. And "small fixes" may be small and "obvious" they
+definitely can regress.
+
+2.0.3 RC-SERIES NEW DRIVER EXEMPTION RULE
+
+The very first release a new driver (or filesystem) is special. New drivers
+are accepted during the rc series. Patches for the same driver then are
+also accepted during the same rc series of a kernel as well as fixes as it
+cannot regress as no previous kernels exists with it.
+
+Once drivers are upstream for one kernel release (say on 2.6.29) the target
+*goal* after the merge window of the next kernel (respectively this would be
+the 2.6.30 rc-series) is to address regressions. Kernel oops/hangs and security
+issues are obviously accepted but the point is these should have also been
+caught earlier as a general development goal. The rc-series focus should really
+be to address regressions.
 
 2.1: THE BIG PICTURE
 
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
1.6.2.2.446.gfbdc0

