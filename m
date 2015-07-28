From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Tue, 28 Jul 2015 16:20:20 +0200
Message-ID: <1438093220.25794.34.camel@stressinduktion.org>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	 <1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com>
	 <87wpxlxrvg.fsf@x220.int.ebiederm.org>
	 <1438085969.25794.14.camel@stressinduktion.org>
	 <87k2tktmk8.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50248 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbbG1OU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:20:26 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id CA23420B42
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 10:20:25 -0400 (EDT)
In-Reply-To: <87k2tktmk8.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-28 at 08:54 -0500, Eric W. Biederman wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> 
> > Hello Eric,
> > 
> > On Mon, 2015-07-27 at 15:33 -0500, Eric W. Biederman wrote:
> > > David Ahern <dsa@cumulusnetworks.com> writes:
> > > 
> > > > Allow tasks to have a default device index for binding sockets. 
> > > > If 
> > > > set
> > > > the value is passed to all AF_INET/AF_INET6 sockets when they 
> > > > are
> > > > created.
> > > > 
> > > > The task setting is passed parent to child on fork, but can be 
> > > > set 
> > > > or
> > > > changed after task creation using prctl (if task has 
> > > > CAP_NET_ADMIN
> > > > permissions). The setting for a socket can be retrieved using 
> > > > prctl().
> > > > This option allows an administrator to restrict a task to only 
> > > > send/receive
> > > > packets through the specified device. In the case of VRF devices 
> > > > this
> > > > option restricts tasks to a specific VRF.
> > > > 
> > > > Correlation of the device index to a specific VRF, ie.,
> > > >    ifindex --> VRF device --> VRF id
> > > > is left to userspace.
> > > 
> > > Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> > > 
> > > Because it is broken by design.  Your routing device is only safe 
> > > for
> > > programs that know it's limitations it is not appropriate for 
> > > general
> > > applications.
> > > 
> > > Since you don't even seen to know it's limitations I think this is 
> > > a
> > > bad path to walk down.
> > 
> > Can you please elaborate about the broken by design?
> > 
> > Different operating systems are already using this approach with 
> > good
> > success. I read your other mail regarding isolation of different 
> > VRFs
> > and I agree that all code which persists state depending solely on 
> > the
> > IP address is affected by this and this must be dealt with and fixed
> > (actually, there aren't too many).
> 
> The size of struct net would tend to disagree with the assertion that
> there are not too many.

netns_frags and inet_peer comes to my mind at first. 

All those data structures simply need to have an opaque id added to the
hash and comparison functions to deal with this problem. And we will
need this in future anyway, as openvswitch will get connection tracking
support and thus the fragmentation engine and icmp rate limiter will
need to be taught about zones in OVS.

> > But I wouldn't call that broken by design. This stuff will get fixed
> > like e.g. cross-talk between fragmentation queues, icmp rate 
> > limiters
> > etc, which could already happen in the past.
> > 
> > What is your opinion on the fundamental approach only from a user
> > perspective? Do you think that is broken, too?
> 
> I think promising something to userspace that a design can not deliver
> is a fundamental problem.

You are still talking about the isolation aspect, right?

Bye,
Hannes
