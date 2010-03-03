From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 03 Mar 2010 11:47:12 -0800
Message-ID: <m13a0hmblr.fsf@fess.ebiederm.org>
References: <4B894564.7080104@parallels.com>
	<m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com>
	<m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr>
	<4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
	<m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com>
	<m1ocj6qljj.fsf@fess.ebiederm.org> <20100303153800.GA937@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48671 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab0CCTrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 14:47:21 -0500
In-Reply-To: <20100303153800.GA937@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 3 Mar 2010 09\:38\:00 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:
>> 
>> > Eric W. Biederman [ebiederm@xmission.com] wrote:
>> > | 
>> > | I think replacing a struct pid for another struct pid allocated in
>> > | descendant pid_namespace (but has all of the same struct upid values
>> > | as the first struct pid) is a disastrous idea.  It destroys the
>> >
>> > True. Sorry, I did not mean we would need a new 'struct pid' for an
>> > existing process. I think we talked earlier of finding a way of attaching
>> > additional pid numbers to the same struct pid.
>> 
>> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
>> to be that you become the idle task aka pid 0, and not the init task pid 1 the
>> implementation is trivial.
>
> Heh, and then (browsing through your copy_process() patch hunks) the next
> forked task becomes the child reaper for the new pidns?  <shrug>  why not
> I guess.
>
> Now if that child reaper then gets killed, will the idle task get killed too?

No.

> And if not, then idle task can just re-populating the new pidns with new
> idle tasks...

After zap_pid_namespace interesting...

> If this brought us a step closer to entering an existing pidns that would
> be one thing, but is there actually any advantage to being able to
> unshare a new pidns?  Oh, I guess there is - PAM can then use it at
> login, which might be neat.

I have to say that the semantics of my patch are unworkable for
unshare.  Unless I am mistaken for PAM to use it requires that the
current process fully change and become what it needs to be.
Requiring an extra fork to fully complete the process is a problem.

Scratch one bright idea.

Eric
