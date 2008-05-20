From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run;
	capabilities error
Date: Tue, 20 May 2008 10:45:42 -0400
Message-ID: <1211294742.7486.137.camel@moss-spartans.epoch.ncsc.mil>
References: <bug-10748-10286@http.bugzilla.kernel.org/>
	 <20080519112835.67ff4133.akpm@linux-foundation.org>
	 <20080520134919.GA8079@sergelap.wowway.com>
	 <1211290714.7486.105.camel@moss-spartans.epoch.ncsc.mil>
	 <1211291902.7486.121.camel@moss-spartans.epoch.ncsc.mil>
	 <877aabc40805200707uf2bd4d8k5d82ee7c9beeb7a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Andrew Morgan <morgan@kernel.org>
To: Amit Shah <shahamit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zombie.ncsc.mil ([144.51.88.131]:39764 "EHLO zombie.ncsc.mil"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765519AbYETOrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 10:47:04 -0400
In-Reply-To: <877aabc40805200707uf2bd4d8k5d82ee7c9beeb7a5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-05-20 at 19:37 +0530, Amit Shah wrote:
> On Tue, May 20, 2008 at 7:28 PM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> >
> > On Tue, 2008-05-20 at 09:38 -0400, Stephen Smalley wrote:
> >> Which means that he is using the dummy security module.
> >> And it appears that a prior commit moved KEEPCAPS handling from
> >> core prctl() to cap_task_prctl(), but didn't replicate it in
> >> the dummy_task_prctl().
> >>
> >> The dummy module really needs to die.
> >
> > Question for the bug reporter:  did you really mean to build a kernel
> > without capabilities support?  Surprise!  They don't really work when
> > disabled.
> 
> No; I was just trying out some random configs. This config worked till
> .25 properly though.

The dummy module is generally in the untenable position of having to lie
to userspace or break the existing capability-related system call
interface.  It should just go away, and make capability the default
module (w/ stubs for the rest of the LSM hooks as with dummy).  Then
CONFIG_SECURITY=n will yield the same result as CONFIG_SECURITY=y w/o
any further options.

-- 
Stephen Smalley
National Security Agency

