From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Tue, 28 Jul 2015 08:54:15 -0500
Message-ID: <87k2tktmk8.fsf@x220.int.ebiederm.org>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	<1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com>
	<87wpxlxrvg.fsf@x220.int.ebiederm.org>
	<1438085969.25794.14.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33822 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbG1OAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:00:54 -0400
In-Reply-To: <1438085969.25794.14.camel@stressinduktion.org> (Hannes Frederic
	Sowa's message of "Tue, 28 Jul 2015 14:19:29 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> Hello Eric,
>
> On Mon, 2015-07-27 at 15:33 -0500, Eric W. Biederman wrote:
>> David Ahern <dsa@cumulusnetworks.com> writes:
>> 
>> > Allow tasks to have a default device index for binding sockets. If 
>> > set
>> > the value is passed to all AF_INET/AF_INET6 sockets when they are
>> > created.
>> > 
>> > The task setting is passed parent to child on fork, but can be set 
>> > or
>> > changed after task creation using prctl (if task has CAP_NET_ADMIN
>> > permissions). The setting for a socket can be retrieved using 
>> > prctl().
>> > This option allows an administrator to restrict a task to only 
>> > send/receive
>> > packets through the specified device. In the case of VRF devices 
>> > this
>> > option restricts tasks to a specific VRF.
>> > 
>> > Correlation of the device index to a specific VRF, ie.,
>> >    ifindex --> VRF device --> VRF id
>> > is left to userspace.
>> 
>> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> 
>> Because it is broken by design.  Your routing device is only safe for
>> programs that know it's limitations it is not appropriate for general
>> applications.
>> 
>> Since you don't even seen to know it's limitations I think this is a
>> bad path to walk down.
>
> Can you please elaborate about the broken by design?
>
> Different operating systems are already using this approach with good
> success. I read your other mail regarding isolation of different VRFs
> and I agree that all code which persists state depending solely on the
> IP address is affected by this and this must be dealt with and fixed
> (actually, there aren't too many).

The size of struct net would tend to disagree with the assertion that
there are not too many.

> But I wouldn't call that broken by design. This stuff will get fixed
> like e.g. cross-talk between fragmentation queues, icmp rate limiters
> etc, which could already happen in the past.
>
> What is your opinion on the fundamental approach only from a user
> perspective? Do you think that is broken, too?

I think promising something to userspace that a design can not deliver
is a fundamental problem.

Eric
