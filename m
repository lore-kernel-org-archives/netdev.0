From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Tue, 28 Jul 2015 18:01:05 +0200
Message-ID: <1438099265.20182.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	 <1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com>
	 <87wpxlxrvg.fsf@x220.int.ebiederm.org>
	 <1438085969.25794.14.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36266 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbbG1QBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:01:10 -0400
Received: by wicgb10 with SMTP id gb10so163350727wic.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:01:09 -0700 (PDT)
In-Reply-To: <1438085969.25794.14.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-28 at 14:19 +0200, Hannes Frederic Sowa wrote:
> Hello Eric,
> 
> On Mon, 2015-07-27 at 15:33 -0500, Eric W. Biederman wrote:
> > David Ahern <dsa@cumulusnetworks.com> writes:
> > 
> > > Allow tasks to have a default device index for binding sockets. If 
> > > set
> > > the value is passed to all AF_INET/AF_INET6 sockets when they are
> > > created.
> > > 
> > > The task setting is passed parent to child on fork, but can be set 
> > > or
> > > changed after task creation using prctl (if task has CAP_NET_ADMIN
> > > permissions). The setting for a socket can be retrieved using 
> > > prctl().
> > > This option allows an administrator to restrict a task to only 
> > > send/receive
> > > packets through the specified device. In the case of VRF devices 
> > > this
> > > option restricts tasks to a specific VRF.
> > > 
> > > Correlation of the device index to a specific VRF, ie.,
> > >    ifindex --> VRF device --> VRF id
> > > is left to userspace.
> > 
> > Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> > 
> > Because it is broken by design.  Your routing device is only safe for
> > programs that know it's limitations it is not appropriate for general
> > applications.
> > 
> > Since you don't even seen to know it's limitations I think this is a
> > bad path to walk down.
> 
> Can you please elaborate about the broken by design?
> 
> Different operating systems are already using this approach with good
> success. I read your other mail regarding isolation of different VRFs
> and I agree that all code which persists state depending solely on the
> IP address is affected by this and this must be dealt with and fixed
> (actually, there aren't too many).
> 
> But I wouldn't call that broken by design. This stuff will get fixed
> like e.g. cross-talk between fragmentation queues, icmp rate limiters
> etc, which could already happen in the past.
> 
> What is your opinion on the fundamental approach only from a user
> perspective? Do you think that is broken, too?

I agree with Eric here.

This sk_bind_dev_if on task_struct is quite a hack.

What will be added next ? An array of dev_if ? netfilter support ?
af_packet support ? What about /proc files and netlink dumps ?

We already have network namespaces. Extend this if needed, instead of
bypassing them.

No need to add something else (with lack of proper reporting for various
tools)
