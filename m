From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 15:49:42 -0800
Message-ID: <20100223234942.GO3604@count0.beaverton.ibm.com>
References: <1263490403.23480.109.camel@bigi>
 <4B50403A.6010507@trash.net>
 <1263568754.23480.142.camel@bigi>
 <m13a0tf17t.fsf@fess.ebiederm.org>
 <1266875729.3673.12.camel@bigi>
 <m1wry46es9.fsf@fess.ebiederm.org>
 <1266931623.3973.643.camel@bigi>
 <m1iq9ocafv.fsf@fess.ebiederm.org>
 <1266934817.3973.654.camel@bigi>
 <m1r5obbu2w.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1r5obbu2w.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2010 at 12:00:55PM -0800, Eric W. Biederman wrote:
> jamal <hadi@cyberus.ca> writes:
> 
> > Added Daniel to the discussion..
> >
> > On Tue, 2010-02-23 at 06:07 -0800, Eric W. Biederman wrote:
> >> jamal <hadi@cyberus.ca> writes:
> >
> >> > Does the point after sys_setns(fd) allow me to do io inside
> >> > ns <name>? Can i do open() and get a fd from ns <name>?
> >> 
> >> Yes.  My intention is that current->nsproxy->net_ns be changed.
> >> We can already change it in unshare so this is feasible.
> >
> > I like it if it makes it as easy as it sounds;-> With lxc,
> > i essentially have to create a proxy process inside the
> > namespace that i use unix domain to open fds inside the ns.
> > Do i still need that?
> 
> That point of the mount to hold a persistent reference to the
> namespace without using a process.

I think technicaly it's still held using processes, only now it's
much more indirect:

netns <- mount <- mount namespace(s) <- process(es)

The big difference is we'd be waiting for all the processes
sharing that mount (or dups of it in multiple mount namespaces) to
exit too -- not just those sharing the netns.

Using a mount requires keeping names for the namespaces themselves
in the kernel which is a problem we've largely avoided so far.
The nscgroup is an example of the messes that creates, I think. And it
further complicates c/r -- we'd need to checkpoint and recreate the
names of the namespaces too. So we'll need a namespace for the names of
the namespaces to make restart reliable won't we? Makes my head spin...

Cheers,
	-Matt Helsley
