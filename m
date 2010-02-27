From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 19:16:36 +0300
Message-ID: <4B894564.7080104@parallels.com>
References: <4B4F24AC.70105@trash.net> <4B4F3A50.1050400@trash.net>	<1263490403.23480.109.camel@bigi> <4B50403A.6010507@trash.net>	<1263568754.23480.142.camel@bigi> <m13a0tf17t.fsf@fess.ebiederm.org>	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1bpfbqajn.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
>> Thanks. What's the problem with setns?
> 
> joining a preexisting namespace is roughly the same problem as
> unsharing a namespace.  We simply haven't figure out how to do it
> safely for the pid and the uid namespaces.

The pid may change after this for sure. What problems do you know
about it? What if we try to allocate the same PID in a new space
or return -EBUSY? This will be a good starting point. If we manage
to fix it later this will not break the API at all.

>>> I have designed these file descriptors to pin the namespaces, so
>>> waiting for them to exit isn't something they can do now.  It makes a
>>> lot of sense to have similar ones that take  weak references to the namespaces
>>> that we can use to wait for a namespace to exit.
>> Yes, I saw this from patches. Eric, I'd very much appreciate if we
>> workout a solution that will allow us to kill two birds with one stone.
>> I do not want to invent yet another bunch of system calls for "taking
>> weak reference".
> 
> Definitely.  I only consider the current interface to be a mushy not
> set in stone.

OK. The interface is good. I just don't want you to send it for an inclusion
until we decide what to do with waiting.

>> As a "brain storm" start up. Can we use inotify/dnotify for this? 
>> Or maybe we should better equip the nsfd call with flags argument and 
>> add a flag for weak reference? In that case - how shall we get a 
>> notification about namespace is dead? With poll? Maybe worth making
>> the sys_close return only when the namespace is dead (by providing a
>> proper ->release callback of a file)?
> 
> We would want poll to work, anything else is a weird work-around.
> The challenging part is that we don't have any infrastructure for
> notifying when a namespace goes away.  So that has to be built before
> we can wire it up to userspace.  I don't expect it is too difficult
> but there is work to be done.

Poll is OK with me. As far as the notification is concerned - that's also
done in OpenVZ. If you are OK to wait for a week or two I can do it for net
namespaces.

> Eric
> 
> 

