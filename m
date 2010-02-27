From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 22:29:00 +0300
Message-ID: <4B89727C.9040602@parallels.com>
References: <4B4F24AC.70105@trash.net> <4B50403A.6010507@trash.net>	<1263568754.23480.142.camel@bigi> <m13a0tf17t.fsf@fess.ebiederm.org>	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>	<4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org>
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
In-Reply-To: <m1iq9io5sc.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
>> Eric W. Biederman wrote:
>>> Pavel Emelyanov <xemul@parallels.com> writes:
>>>
>>>> Thanks. What's the problem with setns?
>>> joining a preexisting namespace is roughly the same problem as
>>> unsharing a namespace.  We simply haven't figure out how to do it
>>> safely for the pid and the uid namespaces.
>> The pid may change after this for sure. What problems do you know
>> about it? What if we try to allocate the same PID in a new space
>> or return -EBUSY? This will be a good starting point. If we manage
>> to fix it later this will not break the API at all.
> 
> Parentage.  The pid is the identity of a process and all kinds of things
> make assumptions in all kinds of strange places.  I don't see how
> waitpid can work if you change the pid.

Agree. But what if we enter a pid space, which is a subnamespace of a current
one? In that case parent will still see the task by its old pid. We can restrict
first version of entering with this rule as well and this restriction will not
block us in typical usecase (I mean enter a container from a host).

> glibc doesn't cope if you change someones pid.

OK, but what if we try to allocate the same pid returning -EBUSY on failure?

My aim is to provide even a restricted enter. For most of the cases this
should work and make our lives easier. So two restrictions currently:
a) enter a sub namespace
b) allocate the same pid as we have now

Hm? :)

>>> Definitely.  I only consider the current interface to be a mushy not
>>> set in stone.
>> OK. The interface is good. I just don't want you to send it for an inclusion
>> until we decide what to do with waiting.
> 
> Sure.  I am get a jump on 2.6.35 not aiming for inclusion this merge
> window.  There is plenty of time.

Good!

>> Poll is OK with me. As far as the notification is concerned - that's also
>> done in OpenVZ. If you are OK to wait for a week or two I can do it for net
>> namespaces.
> 
> Seems reasonable.

OK. I'll spend some time playing with it next week then.

> Eric
> 

Thanks,
Pavel
