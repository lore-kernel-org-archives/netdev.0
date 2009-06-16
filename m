From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Tue, 16 Jun 2009 11:17:05 -0700
Message-ID: <20090616181705.GB31506@tesla>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com> <20090615201934.GA12685@kroah.com> <20090615214735.GE23972@bombadil.infradead.org> <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla> <20090616093401.GA11602@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>,
	"mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090616093401.GA11602-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 16, 2009 at 02:34:01AM -0700, Jouni Malinen wrote:
> On Mon, Jun 15, 2009 at 09:21:14PM -0700, Luis R. Rodriguez wrote:
> 
> > +2.0.2: RC-SERIES RULES
> > +
> > +Rules on what kind of patches are accepted after the merge window closes.
> > +These are patches targeted for the kernel rc-series of a kernel prior
> > +to its release.
> > +
> > + - it must fix a reported regression
> > + - if must fix a reported security hole
> > + - if must fix a reported oops/kernel hang
> 
> 
> s/if/it/ twice..

Thanks, fixed.

> Is there a good reason for documenting different rules for rc-series and
> -stable releases? These three rules look stricter than the ones
> described in stable_kernel_rules.txt:
> 
>  - It must fix a problem that causes a build error (but not for things
>    marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
>    security issue, or some "oh, that's not good" issue.  In short, something
>    critical.

The rc-series rules this patch adds are a summary, so they do indeed appear to be
stricter but I do think new vendor/device ids should be welcomed as well AFAICT,
for instance.

What may be best is to merge these two somehow and refer to the common rules for
both and try to differentiate between them in their respective documentation
section.

But I also think good judgement can be applied, good judgement being defined as
that of a subsystem maintainer, which allows us to simply tell developers to
focus on development and send patches up and the respective maintainer routes
the fixes accordingly.

The spirit of writig this summary is to be clear that rules do exist and that
we cannot simply suggest to read stable_kernel_rules.txt as there are items there
which do not apply.

Reason for trying to add more documentation for this is today there are a lot
companies are working upstream and a better sense of what can get into specific
kernel releases becomes more important and you also have more responsible
developers looking out to ensure their fixes get propagated to the right trees.
So leaving some of these things undocumented, implied or in the dark can turn
out to not be as healthy and IMHO is what lead to the original issue from which
I extracted information to create this summary.

> For example, a fix for data corruption that users can hit relatively
> easily sounds like a good example of something that should really be
> accepted during the rc-phase even if it is not really a regression or
> does not cause a kernel oops/hang.

Agreed.

> "oh, that's not good" issue is somewhat more difficult to comment on,
> but I would expect that there could be some critical issues that really
> would benefit from an exception. What exactly would qualify is something
> that may be not be easily described in a sentence or two, though.
> 
> 
> The main problem I see with having a very hard line on not allowing
> critical fixes (however that would be defined) during the rc-phase is
> that it will take quite a long time to get the fix eventually out. As an
> example, a driver could have a bug that prevents it from working with
> certain subset of devices, but this is noticed only couple of kernel
> releases after the initial driver merge (e.g., for hardware that was not
> yet available for end users at the time the driver was initially
> submitted).

I believe it makes sense to send fixes for new hardware on an old
driver if it is known the fix cannot regress as it does not affect older
hardware.

> In other words, the issue would not be a regression, not a
> security hole, and not an oops/kernel hang. However, it could make the
> driver unusable to large number of users (once the affected hardware
> model becomes available; say in a new laptop).

Agreed. But I think that would fall under the new driver category.

> If an issue is fixed just before a start of the next merge window the
> patch may not have had enough time to go through the maintainers and end
> up in linux-2.6.git in time before the merge window closes. If it
> weren't now allowed in during the rc-phase, it may not go into a stable
> release either (assuming the rc/stable rules are more or less the same)
> and we would be looking something like five month time until the fix
> would actually be released in a proper kernel release. Sure,
> users/distros could take in some additional patches to fix issues they
> care about, but worst case scenarios of close to half a year to fix an
> issue in a kernel release does not sound quite ideal.

Agreed. In the end it seems to come down to the specifics of the patch and
only the maintainer can really be a good judge of whether it should go in
or not. Of course properly documenting each patch helps, and I believe that
in itself may be good enough to address the grey areas.

Here's a new patch with the fix you noted. Also added a little stub about
maintainers judgement, etc.

From: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] Documentation: add documentation summary for rc-series and merge window

This is losely based on previous discussions on linux-kernel [1][2].
Lets also refer people reading the stable rules to
Documentation/development-process/.

Also add the number of days it has taken between releases,
and provide the average for the last 10 releases: 86.0 days.

[1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
[2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2

Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---
 Documentation/development-process/2.Process |   96 ++++++++++++++++++++++++---
 Documentation/stable_kernel_rules.txt       |    5 ++
 2 files changed, 91 insertions(+), 10 deletions(-)

diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
index d750321..c220646 100644
--- a/Documentation/development-process/2.Process
+++ b/Documentation/development-process/2.Process
@@ -7,20 +7,96 @@ course of one year, the kernel has since had to evolve a number of
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
+The merge window is when maintainers of different subsystem send pull
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
+2.0.2: RC-SERIES RULES
+
+Rules on what kind of patches are accepted after the merge window closes.
+These are patches targeted for the kernel rc-series of a kernel prior
+to its release.
+
+ - it must fix a reported regression
+ - it must fix a reported security hole
+ - it must fix a reported oops/kernel hang
+
+This means any small-non-fix code changes, although they might fix an issue,
+will not be accepted. If the patch in question is for a driver that has been
+around for more than a kernel release, then "small fixes" really can't be
+worth all that much. And "small fixes" may be small and "obvious" they
+definitely can regress.
+
+When in doubt consult with your subsystem maintainer or just allow him to
+do the judging of where the patches deserves to go to, a proper commit log
+should help with this effort.
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
1.6.2.2.446.gfbdc0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
