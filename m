From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control. v2
Date: Wed, 03 Mar 2010 12:50:34 -0800
Message-ID: <m11vg1i0yt.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<m18wagy9f3.fsf_-_@fess.ebiederm.org>
	<20100303132931.11afb659@bike.lwn.net>
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
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39697 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab0CCUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 15:50:49 -0500
In-Reply-To: <20100303132931.11afb659@bike.lwn.net> (Jonathan Corbet's message of "Wed\, 3 Mar 2010 13\:29\:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Corbet <corbet@lwn.net> writes:

> Quick question:
>
>> +void set_namespace(unsigned long nstype, void *ns)
>> +{
>> +	struct task_struct *tsk = current;
>> +	struct nsproxy *new_nsproxy;
>> +
>> +	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
>> +	switch(nstype) {
>> +	case NSTYPE_NET:
>> +		put_net(new_nsproxy->net_ns);
>> +		new_nsproxy->net_ns = get_net(ns);
>> +		break;
>> +	}
>> +
>> +	switch_task_namespaces(tsk, new_nsproxy);
>> +}
>
> I assume that, at some future point when more than one namespace type
> is supported, there will be a check to ensure that the type of the given
> namespace matches nstype?  I can imagine all kinds of mayhem that could
> result in the case of an accidental (or intentional) mismatch.
>
> Actually, why does setns() require the nstype parameter at all?  A
> namespace fd is certainly going to have to know what sort of namespace
> it represents...

But userspace might not know for certain and want to check that it is
getting what it expected.  It could be confusing if you think you are
changing your network stack and all of sudden sysv ipc shared memory
was changed instead.

As for the check that nstype is valid that happens earlier in setns.

The plan is to post a patch series with all of the namespace types.


Eric
