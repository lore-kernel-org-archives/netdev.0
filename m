From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: TOE, etc. (was Re: [PATCH Round 3 0/2][RFC] Network Event
	Notifier Mechanism)
Date: Wed, 28 Jun 2006 09:18:53 -0500
Message-ID: <1151504333.14895.25.camel@stevo-desktop>
References: <20060627205050.30723.25753.stgit@stevo-desktop>
	 <E1FvQBu-00018u-00@gondolin.me.apana.org.au>
	 <20060628030400.GA4474@gondor.apana.org.au> <44A1F669.8070606@pobox.com>
	 <20060628033708.GA4922@gondor.apana.org.au>  <44A20311.5050301@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:54548 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1423346AbWF1OSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 10:18:55 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A20311.5050301@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 00:18 -0400, Jeff Garzik wrote:
> Herbert Xu wrote:
> > On Tue, Jun 27, 2006 at 11:24:25PM -0400, Jeff Garzik wrote:
> >> I don't see how that position has changed?
> >>
> >> http://linux-net.osdl.org/index.php/TOE
> > 
> > Well I must say that RDMA over TCP smells very much like TOE.  They've
> > got an ARP table, a routing table, and presumably a TCP stack.
> 
> A PCI device that presents itself as a SCSI controller, but under the 
> hood is really iSCSI-over-TCP smells like TOE.  Running a virtualized 
> Linux guest on top of a proprietary stack [which provides networking 
> services to guests] also smells like TOE.  :)
> 

I wonder if the existing iSCSI solutions handle next host mac addr
changes, pmtu changes, etc?  They _can_, if they implement the entire
ARP and ICMP suites in HW/FW.  Just curious if these vendors also see
merit in the netevent changes I'm proposing...
  
> If a TOE vendors wants to do TOE in a way that is transparent to the 
> kernel, more power to them.  Such non-Linux TCP stack solutions still 
> suffer many of the problems listed at the web page above, but at least 
> they impose no burden on kernel maintenance.
> 
> i.e. we really _do not_ want to get into the habit of co-managing arp 
> tables, routing tables, filtering rules, and dozens of other such 
> resources with multiple remote, independent TCP stack.  We have enough 
> complexity as it is today, coordinating between the random variations of 
> SMP, uniprocessor, and NUMA machines out there.  Not to mention 
> competing with under-the-hood firmware actions (ASF) on NICs.
> 
> As an aside, RDMA over TCP just seems silly.  TCP was _not_ meant to do 
> the things that RDMA users want.  The infiniband/RDMA programming model 
> is an ultra-low-latency polling model where one or two apps are allowed 
> to completely consume the machine, either busy-waiting or processing 
> messages.
> 

With RDMA over TCP, you can get the same ultra-low-latency, interrupt
coalescing or avoidance, and copy avoidance as with Infiniband (with
newly arriving 10Gb RDMA NICs).  The benefit over IB, IMO, is the fact
that your infrastructure is all IP.

If you're interested in a kernel-mode app that benfits from RDMA, then
check out NFS-RDMA, which runs today transparently over Infiniband and
RDMA/TCP devices using the Infiniband RDMA-CM and verbs with minor
changes to support RDMA/TCP devices. 

http://sourceforge.net/projects/nfs-rdma/


Steve.


