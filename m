From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run;
	capabilities error
Date: Tue, 20 May 2008 09:58:22 -0400
Message-ID: <1211291902.7486.121.camel@moss-spartans.epoch.ncsc.mil>
References: <bug-10748-10286@http.bugzilla.kernel.org/>
	 <20080519112835.67ff4133.akpm@linux-foundation.org>
	 <20080520134919.GA8079@sergelap.wowway.com>
	 <1211290714.7486.105.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shahamit@gmail.com,
	Andrew Morgan <morgan@kernel.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie.ncsc.mil ([144.51.88.131]:59306 "EHLO zombie.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754354AbYETOAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 10:00:48 -0400
In-Reply-To: <1211290714.7486.105.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-05-20 at 09:38 -0400, Stephen Smalley wrote:
> On Tue, 2008-05-20 at 08:49 -0500, Serge E. Hallyn wrote:
> > Quoting Andrew Morton (akpm@linux-foundation.org):
> > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > bugzilla web interface).
> > > 
> > > On Mon, 19 May 2008 06:25:00 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > > 
> > > > http://bugzilla.kernel.org/show_bug.cgi?id=10748
> > > > 
> > > >            Summary: dhclient fails to run; capabilities error
> > > >            Product: Networking
> > > >            Version: 2.5
> > > >      KernelVersion: 2.6.26-rc2
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: normal
> > > >           Priority: P1
> > > >          Component: IPV4
> > > >         AssignedTo: shemminger@linux-foundation.org
> > > >         ReportedBy: shahamit@gmail.com
> > > > 
> > > > 
> > > > Latest working kernel version: 2.6.25
> > > > Earliest failing kernel version: 2.6.26-rc1
> > > > Distribution: Kubuntu Hardy
> > > > Hardware Environment: AMD
> > > > Software Environment:
> > > > Problem Description: On a default Kubuntu Hardy install, I fetched the git tree
> > > > from Linus; compiled and installed the kernel. This persists even with
> > > > 2.6.26-rc2+ (commit f26a3988917913b3d11b2bd741601a2c64ab9204)
> > > > 
> > > > If this isn't known, I'll bisect and report the bad commit
> > > > 
> > > > Steps to reproduce: 'sudo dhclient eth2' returns
> > > > 
> > > > drop_privileges: could not keep capabilities: Invalid argument
> > > > 
> > > > eth2 is an e1000e card.
> > > > 
> > > > 
> > > 
> > > whoa, weird.  Could you please run `sudo strace -f dhclient eth2' and send us
> > > the last page or so of output?
> > 
> > Also, please send your .config, or at least the result of
> > grep SECURITY .config
> 
> His .config was attached to the bugzilla.
> CONFIG_SECURITY=y
> CONFIG_SECURITY_NETWORK=y
> # CONFIG_SECURITY_NETWORK_XFRM is not set
> # CONFIG_SECURITY_CAPABILITIES is not set
> CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
> # CONFIG_SECURITY_SELINUX is not set
> 
> Which means that he is using the dummy security module.
> And it appears that a prior commit moved KEEPCAPS handling from
> core prctl() to cap_task_prctl(), but didn't replicate it in
> the dummy_task_prctl().
> 
> The dummy module really needs to die.

Question for the bug reporter:  did you really mean to build a kernel
without capabilities support?  Surprise!  They don't really work when
disabled.

-- 
Stephen Smalley
National Security Agency

