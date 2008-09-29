From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Mon, 29 Sep 2008 12:49:24 -0400
Message-ID: <1222706964.5429.22.camel@moss-spartans.epoch.ncsc.mil>
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
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Paul Moore <paul.moore-VXdhtT5mjnY@public.gmane.org>, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1221762850.24048.107.camel-/ugcdrsPCSfIm9DtXLC9OUVfdvkotuLY+aIohriVLy8@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Thu, 2008-09-18 at 14:34 -0400, Stephen Smalley wrote:
> On Thu, 2008-09-18 at 11:09 -0700, Eric W. Biederman wrote:
> > Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> writes:
> > 
> > > On Thu, 2008-09-18 at 08:38 -0400, Stephen Smalley wrote:
> > >> I do however think that the mantra that we can't require users to update
> > >> policy for kernel changes is unsupportable in general.  The precise set
> > >> of permission checks on a given operation is not set in stone and it is
> > >> not part of the kernel/userland interface/contract.  Policy isn't
> > >> "userspace"; it governs what userspace can do, and it has to adapt to
> > >> kernel changes.
> > >
> > > I should note here that for changes to SELinux, we have gone out of our
> > > way to avoid such breakage to date through the introduction of
> > > compatibility switches, policy flags to enable any new checks, etc
> > > (albeit at a cost in complexity and ever creeping compatibility code).
> > > But changes to the rest of the kernel can just as easily alter the set
> > > of permission checks that get applied on a given operation, and I don't
> > > think we are always going to be able to guarantee that new kernel + old
> > > policy will Just Work. 
> > 
> > I know of at least 2 more directories that I intend to turn into
> > symlinks into somewhere under /proc/self.  How do we keep from
> > breaking selinux policies when I do that?
> 
> I suspect we could tweak the logic in selinux_proc_get_sid() to always
> label all symlinks under /proc with the base proc_t type already used
> for e.g. /proc/self, at which point existing policies would be ok.

FWIW, a fix for this issue has been applied to:
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6#next

The particular commit can be viewed at:
http://git.kernel.org/?p=linux/kernel/git/jmorris/security-testing-2.6.git;a=commit;h=ea6b184f7d521a503ecab71feca6e4057562252b

This should address not only the /proc/net breakage but also any future
changes to turn existing directories into symlinks.

-- 
Stephen Smalley
National Security Agency
