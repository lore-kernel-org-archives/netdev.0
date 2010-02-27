From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 01:04:47 -0800
Message-ID: <m1mxyvrqvk.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com>
	<m13a0nwu6p.fsf@fess.ebiederm.org> <4B88D80A.8010701@parallels.com>
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
In-Reply-To: <4B88D80A.8010701@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 11\:30\:02 +0300")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

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
> Exactly. Please add at least the NSTYPE_NSPROXY or whatever, that will
> pin all namespaces of a given pid from the very beginning.

For nsfd(2) that is doable.  At least for now setns can't restore it.

>> Why don't we have a syscall that allows us to enter every namespace?
>
> This one is done in the patch, no?
>
> Although the approach is OK for me, there's one design issue, that came
> up to my mind recently: can we use this fd to wail for a namespace to 
> stop? I currently don't see this ability, but this is something I require
> badly.

I have designed these file descriptors to pin the namespaces, so
waiting for them to exit isn't something they can do now.  It makes a
lot of sense to have similar ones that take  weak references to the namespaces
that we can use to wait for a namespace to exit.

Eric
