From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 14:24:30 -0800
Message-ID: <m14okqqwo1.fsf@fess.ebiederm.org>
References: <4B92C886.9020507@free.fr> <m1fx4bxlfy.fsf@fess.ebiederm.org>
	<4B952BBE.6070507@free.fr> <m11vfuvi1t.fsf@fess.ebiederm.org>
	<4B9556A9.60206@free.fr> <m11vfusgsa.fsf@fess.ebiederm.org>
	<4B95611C.5060403@free.fr> <m1sk8ar15b.fsf@fess.ebiederm.org>
	<4B956852.7050804@free.fr> <m1lje2qzf4.fsf@fess.ebiederm.org>
	<20100308214945.GA26617@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37941 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537Ab0CHWYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 17:24:37 -0500
In-Reply-To: <20100308214945.GA26617@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 8 Mar 2010 15\:49\:45 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>> I guess my meaning is I was expecting.
>> child = fork();
>> if (child == 0) {
>> 	execve(...);
>> }
>> waitpid(child);
>> 
>> This puts /bin/sh in the container as well.
>> 
>> I'm not certain about the /proc/self thing I have never encountered that.
>> But I guess if your pid is outside of the pid namespace of that instance
>> of proc /proc/self will be a broken symlink.
>> 
>> Eric
>
> Hmm, worse than a broken symlink, will it be a wrong symlink if just
> the right pid is created in the container?

It won't happen. readlink and followlink are both based on 
task_tgid_nr_ns(current, ns_of_proc).

Which fails if your process is not known in that pid namespace.

Eric
