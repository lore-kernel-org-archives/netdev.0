From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 14:16:43 -0800
Message-ID: <m1zl2vtzg4.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com>
	<m13a0nwu6p.fsf@fess.ebiederm.org> <4B8843FE.4000404@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Oren Laadan <orenl@cs.columbia.edu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B8843FE.4000404@cs.columbia.edu> (Oren Laadan's message of "Fri\, 26 Feb 2010 16\:58\:22 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oren Laadan <orenl@cs.columbia.edu> writes:

> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@parallels.com> writes:
>>
>>>>> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
>>>>> I currently have a way to create all namespaces we have with one
>>>>> syscall. Why don't we have an ability to enter them all with one syscall?
>>>> The CLONE_NEWXXX series of bits has been an royal pain to work with,
>>>> and it appears to be unnecessary complications for no gain.
>>> That's the answer for the "Yet another set..." question.
>>> How about the "Why don't we have..." one?
>>
>> I am not certain which question you are asking:
>>
>> Why don't we have an ability to enter all namespaces with one syscall
>> invocation?
>
> That's how I understood the question, and I, too, wonder why not ?
>
> By the way, an alternative to using bitmap is to change the prototype
> of setns() to accept an array of FD's:
>
> 	int setns(int *fds, int nfds);
>
> So the process will atomically enter all the namespaces as specified
> by the FDs.

We could.  Mostly I implemented things in the simplest way possible.

Semantically I know of no reason why need to enter more than one namespace
at once, and I don't expect entering a namespace to be on anyone's fast
path so every last drop of performance was not crucial.

The only justification I can think of for more than one namespace at a
time is that because we have a synchronize_rcu() in the kernel we can
loop in the kernel much more quickly than we can loop in userspace.

Eric
