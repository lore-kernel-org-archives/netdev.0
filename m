From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC] Documentation: add documentation for rc-series and merge window
Date: Mon, 15 Jun 2009 16:12:51 -0400
Message-ID: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is losely based on previous discussions on linux-kernel [1][2].

[1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
[2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2

Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---

I have run into issues when trying to explain this and policies
for the rc-series, it seems there is no place that documents this
clearly so here is an attempt based on some previous discussions.
Not sure if I got it all correct, so feedback is welcomed. I do think
clarifying this a little should help.

I was also not sure if Documentation/stable_kernel_rules.txt is the best
splace for this as well, please let me know.

As a side note I'll say that I have noticed that it seems some companies
like to target getting stuff in by certain kernel releases, and for that
I think what may help is a heads up for when it seems each subsystem's
merge window will be closing up by.

I also realize the difficulty in trying to target certain schedules for a
kernel release but when that release date becomes clearer it would be nicer
to further communicate that accross the lists. Not sure if anything better
can be done today other than maybe highlighting more clearer on each rc release
where it seems we are. I myself try to track this on a google calendar and
it seems others do too [1]. One way or another as we get closer to a release
I think it would still be nicer to get more feedback to better predict this.

[1] http://lwn.net/Articles/253955/

 Documentation/stable_kernel_rules.txt |   69 +++++++++++++++++++++++++++++++++
 1 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
index a452227..494baa5 100644
--- a/Documentation/stable_kernel_rules.txt
+++ b/Documentation/stable_kernel_rules.txt
@@ -1,5 +1,74 @@
 Everything you ever wanted to know about Linux 2.6 -stable releases.
 
+Stable kernel releases
+----------------------
+
+Stable kernels are released when they are ready. This means there is no
+strict guidelines for sticking to specific dates for a kernel release.
+
+Merge window
+------------
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
+posted. If you insist on targetting a kernel release for deadlines you can
+try to be aware of the current rc cycle development and how soon it seems
+the next stable kernel relase will be made. When Linus notes the last rc
+cycle released may be the last -- that is a good sign you should already
+have all your development done and merged in the respective development
+tree. If your code is not ready and merged into the respective maintainers
+tree prior to the announced last potential rc kernel release chances are
+you missed getting your code in for the next kernel merge window.
+Excemptions here are new drivers, covered below.
+
+rc-series rules
+---------------
+
+Rules on what kind of patches are accepted after the merge window closes.
+These are patches targetted for the kernel rc-series of a kernel prior
+to its release.
+
+ - it must fix a reported regression
+ - if must fix a reported security hole
+ - if must fix a reported oops/kernel hang
+
+This means any small-non-fix code changes, although they mix fix an issue,
+will not be accepted. If the patch in question is for a driver that has been
+around for more than a kernel release, then "small fixes" really can't be
+worth all that much. And "small fixes" may be small and "obvious" they
+definitely can regress.
+
+rc-series new driver excemption rule
+------------------------------------
+
+The very first release a new driver (or filesystem) is special. New drivers
+are accepted during the rc series. Patches for the same driver then are
+also accepted uring the same rc series of a kernel as well as fixes as it
+cannot regress as no previous kernels exists with it.
+
+Once drivers are upstream for one kernel release (say on 2.6.29) the target
+*goal* after the merge window of the next kernel (respectively this would be
+the 2.6.30 rc-series) is to address address regressions. Kernel oops/hangs
+and security issues are obviously accepted but the point is these should have
+also been caught earlier as a general development goal. The rc-series focus
+should really be to address regressions.
+
+Stable kernel rules
+-------------------
+
 Rules on what kind of patches are accepted, and which ones are not, into the
 "-stable" tree:
 
-- 
1.6.2.2.446.gfbdc0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
