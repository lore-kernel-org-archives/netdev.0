From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 13:05:23 -0800
Message-ID: <m18wa9glpo.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com>
	<m13a0nwu6p.fsf@fess.ebiederm.org> <4B88D80A.8010701@parallels.com>
	<m1mxyvrqvk.fsf@fess.ebiederm.org> <4B88E431.6040609@parallels.com>
	<m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8ECD99.3040107@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Oren Laadan <orenl@cs.columbia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40629 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab0CCVF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 16:05:28 -0500
In-Reply-To: <4B8ECD99.3040107@cs.columbia.edu> (Oren Laadan's message of "Wed\, 03 Mar 2010 15\:59\:05 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oren Laadan <orenl@cs.columbia.edu> writes:

> Daniel Lezcano wrote:
>>
>> I agree with all the points you and Pavel you talked about but I don't feel
>> comfortable to have the current process to switch the pid namespace because of
>> the process tree hierarchy (what will be the parent of the process when you
>> enter the pid namespace for example). What is the difference with the
>> sys_bindns or the sys_hijack, proposed a couple of years ago ?
>>
>> I did a suggestion some weeks ago about a new syscall 'cloneat' where the
>> child process becomes the child of the targeted process specified in the
>> syscall. Maybe it would be interesting to replace the 'setns' by, or add, a
>> cloneat' syscall with the file descriptor passed as parameter. The
>> copy_process function shall not use the nsproxy of the caller but the one
>> provided in the fd argument.
>>
>> The newly created process becomes the child of the process where we retrieve
>> the namespace with nsfd and this one have to 'waitpid' it, (the caller of
>> cloneat' can not wait it). It's a bit similar with the CLONE_PARENT flag,
>> except the creation order is inverted (the father creates for the child).
>>
>> So when entering the container, we specify the pid 1 of the container which is
>> usually a child reaper.
>>
>> Does it make sense ?
>
> For what it's worth, I think that this suggestion (cloneat) is the
> so far the cleanest to allow a process to enter an existing namespace.

If the goal is to enter a container you are probably right.  I don't
think I have seen how scary the cloneat code is.

At least for the network namespace there is a lot of value in being
able to just change that single namespace.  Having multiple logical
network stacks has it's challenges but has a lot of practical
applications.  Especially when there is the possibility of private
ipv4 addresses overlapping, or you have interfaces where you never
want to forward between them but you want forwarding enabled.

Eric
