From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Thu, 18 Sep 2008 09:03:00 -0400
Message-ID: <1221742980.24048.26.camel@moss-spartans.epoch.ncsc.mil>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	 <1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	 <20080917125053.1f9ecf37.akpm@linux-foundation.org>
	 <200809171724.36269.paul.moore@hp.com>
	 <20080917144842.7df59f9e.akpm@linux-foundation.org>
	 <m17i9axv1q.fsf@frodo.ebiederm.org>
	 <1221741521.24048.17.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Moore <paul.moore@hp.com>, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie2.ncsc.mil ([144.51.88.133]:44097 "EHLO zombie2.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717AbYIRNDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 09:03:48 -0400
In-Reply-To: <1221741521.24048.17.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-09-18 at 08:38 -0400, Stephen Smalley wrote:
> On Wed, 2008-09-17 at 15:32 -0700, Eric W. Biederman wrote:
> > Andrew Morton <akpm@linux-foundation.org> writes:
> > 
> > > We don't even know the extent of the damage yet.  Which distros were
> > > affected? With which versions of which userspace packages?
> > 
> > This seems to me to be an extremely fragile selinux user space policy.
> > In their code that derives security labels from path names.
> > Why don't we have AppArmor in the kernel again?
> 
> I think I explained that one before - in the case of /proc, the only
> stable basis we have for deducing the security properties / protection
> requirements for a given entry is its name, and its name can be reliably
> constructed from the kernel's internal proc_dir_entry tree w/o any
> ambiguity or potential for userspace manipulation (unlike the pathname
> returned by d_path for a normal file).  I'd agree that it isn't optimal,
> but it is what we have.
> 
> > Further I don't see how we could have possibly have supported that user space
> > policy.  How can we apply a user space defined label required by the selinux
> > policy to a symlink that did not exist?
> 
> I'm not blaming anyone here, or trying to argue that the /proc/net
> changes should be reverted.  What happened here is that a kernel
> interface (/proc/net) changed in a subtle way that had a side effect on
> permission checking, and we tried to hide that change at the time (in
> terms of ensuring that the new /proc/self/net tree would still be
> labeled correctly), and we missed the fact that there would still be a
> new check on the symlink read that wouldn't be covered by existing
> policy.
> 
> > Everything here sounds to me like that selinux policy is impossibly brittle.
> > And anything that is that brittle I have no intention in claiming is a bug
> > in proc.
> 
> I'm not arguing that this is a bug in proc or in selinux for that
> matter.
> 
> I do however think that the mantra that we can't require users to update
> policy for kernel changes is unsupportable in general.  The precise set
> of permission checks on a given operation is not set in stone and it is
> not part of the kernel/userland interface/contract.  Policy isn't
> "userspace"; it governs what userspace can do, and it has to adapt to
> kernel changes.

I should note here that for changes to SELinux, we have gone out of our
way to avoid such breakage to date through the introduction of
compatibility switches, policy flags to enable any new checks, etc
(albeit at a cost in complexity and ever creeping compatibility code).
But changes to the rest of the kernel can just as easily alter the set
of permission checks that get applied on a given operation, and I don't
think we are always going to be able to guarantee that new kernel + old
policy will Just Work. 

> Users who are willing/able to run the latest kernel on their own w/o
> waiting for a coordinated update of kernel and policy from their
> distribution ought to be able to create a local policy module - it isn't
> rocket science, and they can always fall back on audit2allow if they
> need to do so.

-- 
Stephen Smalley
National Security Agency

