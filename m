From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 11:08:35 -0800
Message-ID: <m1iq9io5sc.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <4B50403A.6010507@trash.net>
	<1263568754.23480.142.camel@bigi> <m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi> <m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi> <m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi> <m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com> <m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
	<4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org>
	<4B894564.7080104@parallels.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56660 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030653Ab0B0TIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 14:08:45 -0500
In-Reply-To: <4B894564.7080104@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 19\:16\:36 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@parallels.com> writes:

> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@parallels.com> writes:
>> 
>>> Thanks. What's the problem with setns?
>> 
>> joining a preexisting namespace is roughly the same problem as
>> unsharing a namespace.  We simply haven't figure out how to do it
>> safely for the pid and the uid namespaces.
>
> The pid may change after this for sure. What problems do you know
> about it? What if we try to allocate the same PID in a new space
> or return -EBUSY? This will be a good starting point. If we manage
> to fix it later this will not break the API at all.

Parentage.  The pid is the identity of a process and all kinds of things
make assumptions in all kinds of strange places.  I don't see how
waitpid can work if you change the pid.

glibc doesn't cope if you change someones pid.

>> Definitely.  I only consider the current interface to be a mushy not
>> set in stone.
>
> OK. The interface is good. I just don't want you to send it for an inclusion
> until we decide what to do with waiting.

Sure.  I am get a jump on 2.6.35 not aiming for inclusion this merge
window.  There is plenty of time.

>
> Poll is OK with me. As far as the notification is concerned - that's also
> done in OpenVZ. If you are OK to wait for a week or two I can do it for net
> namespaces.

Seems reasonable.

Eric
