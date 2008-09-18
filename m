From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Thu, 18 Sep 2008 14:34:10 -0400
Message-ID: <1221762850.24048.107.camel@moss-spartans.epoch.ncsc.mil>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	 <1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	 <20080917125053.1f9ecf37.akpm@linux-foundation.org>
	 <200809171724.36269.paul.moore@hp.com>
	 <20080917144842.7df59f9e.akpm@linux-foundation.org>
	 <m17i9axv1q.fsf@frodo.ebiederm.org>
	 <1221741521.24048.17.camel@moss-spartans.epoch.ncsc.mil>
	 <1221742980.24048.26.camel@moss-spartans.epoch.ncsc.mil>
	 <m18wtpuy04.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Moore <paul.moore@hp.com>, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, Eric Paris <eparis@parisplace.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:49578 "EHLO mummy.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436AbYIRSfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 14:35:44 -0400
In-Reply-To: <m18wtpuy04.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-09-18 at 11:09 -0700, Eric W. Biederman wrote:
> Stephen Smalley <sds@tycho.nsa.gov> writes:
> 
> > On Thu, 2008-09-18 at 08:38 -0400, Stephen Smalley wrote:
> >> I do however think that the mantra that we can't require users to update
> >> policy for kernel changes is unsupportable in general.  The precise set
> >> of permission checks on a given operation is not set in stone and it is
> >> not part of the kernel/userland interface/contract.  Policy isn't
> >> "userspace"; it governs what userspace can do, and it has to adapt to
> >> kernel changes.
> >
> > I should note here that for changes to SELinux, we have gone out of our
> > way to avoid such breakage to date through the introduction of
> > compatibility switches, policy flags to enable any new checks, etc
> > (albeit at a cost in complexity and ever creeping compatibility code).
> > But changes to the rest of the kernel can just as easily alter the set
> > of permission checks that get applied on a given operation, and I don't
> > think we are always going to be able to guarantee that new kernel + old
> > policy will Just Work. 
> 
> I know of at least 2 more directories that I intend to turn into
> symlinks into somewhere under /proc/self.  How do we keep from
> breaking selinux policies when I do that?

I suspect we could tweak the logic in selinux_proc_get_sid() to always
label all symlinks under /proc with the base proc_t type already used
for e.g. /proc/self, at which point existing policies would be ok.

> For comparison how do we handle sysfs?

Unresolved; presently has a single label for all nodes.
See https://bugzilla.redhat.com/show_bug.cgi?id=228902
for prior discussion of fine-grained labeling support for sysfs.

> How do we handle device nodes in tmpfs?

udev has selinux support - looks up the appropriate context in a
userland config file (file_contexts) via libselinux matchpathcon(3) and
sets it upon creation.  tmpfs has long supported getting/setting
security.* attributes.

> Ultimately do we want to implement xattrs and inotify on /proc?  
> Or is there another way that would simplify maintenance?

If proc supported setxattr, then I suppose early userspace could label
it instead of the kernel needing to determine a label internally.  But
not sure how we'd cleanly migrate to avoid breakage with old userspace.

-- 
Stephen Smalley
National Security Agency

