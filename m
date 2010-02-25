From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Thu, 25 Feb 2010 22:31:49 +0100
Message-ID: <4B86EC45.3060005@free.fr>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi> <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:60384 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933805Ab0BYVby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 16:31:54 -0500
In-Reply-To: <m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Introduce two new system calls:
> int nsfd(pid_t pid, unsigned long nstype);
> int setns(unsigned long nstype, int fd);
>
> These two new system calls address three specific problems that can
> make namespaces hard to work with.
> - Namespaces require a dedicated process to pin them in memory.
> - It is not possible to use a namespace unless you are the
>   child of the original creator.
> - Namespaces don't have names that userspace can use to talk
>   about them.
>
> The nsfd() system call returns a file descriptor that can
> be used to talk about a specific namespace, and to keep
> the specified namespace alive.
>
> The fd returned by nsfd() can be bind mounted as:
> mount --bind /proc/self/fd/N /some/filesystem/path
> to keep the namespace alive indefinitely as long as
> it is mounted.
>
> open works on the fd returned by nsfd() so another
> process can get a hold of it and do interesting things.
>
> Overall that allows for persistent naming of namespaces
> according to userspace policy.
>
> setns() allows changing the namespace of the current process
> to a namespace that originates with nsfd().
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>   

Is it planned to support all the namespaces for 'nsfd' ?
 I mean will it be possible to specify an Or'ed combination of nstype to 
grab a reference for several namespaces at a time of the targeted process ?

for example : nsfd( 1234, NSTYPE_NET | NSTYPE_IPC, NSTYPE_MNT)
