From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Fri, 19 Sep 2008 13:07:45 -0400
Message-ID: <1221844065.25857.69.camel@moss-spartans.epoch.ncsc.mil>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	 <1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	 <20080917125053.1f9ecf37.akpm@linux-foundation.org>
	 <200809171724.36269.paul.moore@hp.com>
	 <20080917144842.7df59f9e.akpm@linux-foundation.org>
	 <m17i9axv1q.fsf@frodo.ebiederm.org>
	 <1221741521.24048.17.camel@moss-spartans.epoch.ncsc.mil>
	 <1221742980.24048.26.camel@moss-spartans.epoch.ncsc.mil>
	 <m18wtpuy04.fsf@frodo.ebiederm.org>
	 <1221762850.24048.107.camel@moss-spartans.epoch.ncsc.mil>
	 <alpine.DEB.1.10.0809190958070.26104@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paul Moore <paul.moore@hp.com>, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, Eric Paris <eparis@parisplace.org>
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie2.ncsc.mil ([144.51.88.133]:44804 "EHLO zombie2.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbYISRJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 13:09:07 -0400
In-Reply-To: <alpine.DEB.1.10.0809190958070.26104@asgard.lang.hm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-09-19 at 09:58 -0700, david@lang.hm wrote:
> On Thu, 18 Sep 2008, Stephen Smalley wrote:
> 
> > On Thu, 2008-09-18 at 11:09 -0700, Eric W. Biederman wrote:
> >> Stephen Smalley <sds@tycho.nsa.gov> writes:
> >>
> >>> On Thu, 2008-09-18 at 08:38 -0400, Stephen Smalley wrote:
> >>>> I do however think that the mantra that we can't require users to update
> >>>> policy for kernel changes is unsupportable in general.  The precise set
> >>>> of permission checks on a given operation is not set in stone and it is
> >>>> not part of the kernel/userland interface/contract.  Policy isn't
> >>>> "userspace"; it governs what userspace can do, and it has to adapt to
> >>>> kernel changes.
> >>>
> >>> I should note here that for changes to SELinux, we have gone out of our
> >>> way to avoid such breakage to date through the introduction of
> >>> compatibility switches, policy flags to enable any new checks, etc
> >>> (albeit at a cost in complexity and ever creeping compatibility code).
> >>> But changes to the rest of the kernel can just as easily alter the set
> >>> of permission checks that get applied on a given operation, and I don't
> >>> think we are always going to be able to guarantee that new kernel + old
> >>> policy will Just Work.
> >>
> >> I know of at least 2 more directories that I intend to turn into
> >> symlinks into somewhere under /proc/self.  How do we keep from
> >> breaking selinux policies when I do that?
> >
> > I suspect we could tweak the logic in selinux_proc_get_sid() to always
> > label all symlinks under /proc with the base proc_t type already used
> > for e.g. /proc/self, at which point existing policies would be ok.
> 
> so if proc is mounted anywhere other then /proc the selinux policy would 
> do odd things?

No, the logic doesn't care where proc is mounted.  Only the name
relative to the root of proc is used.

-- 
Stephen Smalley
National Security Agency

