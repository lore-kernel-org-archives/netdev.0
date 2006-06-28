From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: TOE, etc. (was Re: [PATCH Round 3 0/2][RFC] Network Event
	Notifier Mechanism)
Date: Wed, 28 Jun 2006 09:31:43 -0500
Message-ID: <1151505103.14895.31.camel@stevo-desktop>
References: <20060627205050.30723.25753.stgit@stevo-desktop>
	 <E1FvQBu-00018u-00@gondolin.me.apana.org.au>
	 <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com>
	 <20060628033708.GA4922@gondor.apana.org.au> <44A20311.5050301@pobox.com>
	 <20060628042959.GA5561@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:19524 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1423362AbWF1Obp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 10:31:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060628042959.GA5561@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 14:29 +1000, Herbert Xu wrote:
> On Wed, Jun 28, 2006 at 12:18:25AM -0400, Jeff Garzik wrote:
> > 
> > A PCI device that presents itself as a SCSI controller, but under the 
> > hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
> > Linux guest on top of a proprietary stack [which provides networking 
> > services to guests] also smells like TOE.  :)
> 
> Agreed.  However, when they start adding hooks to the ARP table, the
> routing table, and PMTU management, it begs the question what more is
> there to add for TOE (well, user-space driven TOE at least)?
>  
> > Unfortunately I don't have more details, so you just get a generalized 
> > rant :)
> 
> OK, the patch under discussion here adds hooks to all the stuff in the
> previous paragraph for the purpose of RDMA over TCP (well I must say
> that the exact RDMA application/hardware has never been clearly given
> but this is what I can gather from the previous posts).

There are Ammasso and Chelsio RDMA/Ethernet drivers in the openib.org
svn iwarp branch today.  The goal is to submit them for review and
inclusion into linux.  The Ammasso driver has been through 3 review
cycles on lkml and netdev.  There are other vendors with drivers, but
they're currently not disclosing any information to me about their
status.

Applications: 

kernel: NFS-RDMA, iSER, RDP.  
user:  MPI, uDAPL (both middle ware).

The Ammasso driver is a different model.  It actually has a full
TCP/ARP/ICMP stack and doesn't require these hooks.  But the RDMA/TCP
model defined and implemented, I think, by most vendors is a model where
the HW is doing a limited TCP offload, relying on the native stack for
L2 and L3 integration (as described in the netevent patch).


> Put it another way, I think the dividing line between TOE and iSCSI or
> virtualisation is exactly the interface between them and the Linux kernel.
> If the interface is an existing one such as SCSI or standard IP then it's
> OK.  However, when it starts poking in the guts of the Linux stack I'd say
> that it has crossed the line.
> 

Don't these netevent hooks have utility for other purposes?  IE:  Should
we really shoot changes to linux _just because_ they might possibly
enable TOE? 

Steve.

