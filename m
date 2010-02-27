From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 01:42:52 -0800
Message-ID: <m1bpfbqajn.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <4B4F3A50.1050400@trash.net>
	<1263490403.23480.109.camel@bigi> <4B50403A.6010507@trash.net>
	<1263568754.23480.142.camel@bigi> <m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B88E431.6040609@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 12\:21\:53 +0300")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

> Thanks. What's the problem with setns?

joining a preexisting namespace is roughly the same problem as
unsharing a namespace.  We simply haven't figure out how to do it
safely for the pid and the uid namespaces.

>> I have designed these file descriptors to pin the namespaces, so
>> waiting for them to exit isn't something they can do now.  It makes a
>> lot of sense to have similar ones that take  weak references to the namespaces
>> that we can use to wait for a namespace to exit.
>
> Yes, I saw this from patches. Eric, I'd very much appreciate if we
> workout a solution that will allow us to kill two birds with one stone.
> I do not want to invent yet another bunch of system calls for "taking
> weak reference".

Definitely.  I only consider the current interface to be a mushy not
set in stone.

> As a "brain storm" start up. Can we use inotify/dnotify for this? 
> Or maybe we should better equip the nsfd call with flags argument and 
> add a flag for weak reference? In that case - how shall we get a 
> notification about namespace is dead? With poll? Maybe worth making
> the sys_close return only when the namespace is dead (by providing a
> proper ->release callback of a file)?

We would want poll to work, anything else is a weird work-around.
The challenging part is that we don't have any infrastructure for
notifying when a namespace goes away.  So that has to be built before
we can wire it up to userspace.  I don't expect it is too difficult
but there is work to be done.

Eric

