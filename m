From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Wed, 05 Jul 2006 12:50:34 -0500
Message-ID: <1152121834.12325.10.camel@stevo-desktop>
References: <adawtazgawi.fsf@cisco.com>
	 <20060630.141658.34759102.davem@davemloft.net>
	 <1151708503.11835.8.camel@trinity.ogc.int>  <200607011626.04539.ak@suse.de>
	 <1152119382.20248.51.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, David Miller <davem@davemloft.net>,
	rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:38488 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S964930AbWGERug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 13:50:36 -0400
To: Tom Tucker <tom@opengridcomputing.com>
In-Reply-To: <1152119382.20248.51.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-05 at 12:09 -0500, Tom Tucker wrote:
> On Sat, 2006-07-01 at 16:26 +0200, Andi Kleen wrote:
> > On Saturday 01 July 2006 01:01, Tom Tucker wrote:
> > > On Fri, 2006-06-30 at 14:16 -0700, David Miller wrote:
> > > 
> > > > The TOE folks have tried to submit their hooks and drivers
> > > > on several occaisions, and we've rejected it every time.
> > > 
> > > iWARP != TOE
> > 
> > Perhaps a good start of that discussion David asked for would 
> > be if you could give us an overview of the differences
> > and how you avoid the TOE problems.
> 
> I think Roland already gave the high-level overview. For those
> interested in some of the details, the API for iWARP transports was
> originally conceived independently from IB and is documented in the
> RDMAC Verbs Specification found here:
> 
> http://www.rdmaconsortium.org/home/draft-hilland-iwarp-verbs-v1.0-RDMAC.pdf
> 
> The protocols, etc... are available here:
> http://www.ietf.org/html.charters/rddp-charter.html
> 
> As Roland mentioned, the RDMAC verbs are *very* similar to the IB verbs
> and so when we were thinking about how to design an API for iWARP we
> concluded it would be best to leverage the tremendous amount of work
> already done for IB by OpenFabrics and then work iteratively to extend
> this API to include features unique to iWARP. This work has been ongoing
> since September of 2005. 
> 
> There is an open source svn repository available for the iWARP source at
> https://openib.org/svn/gen2/branches/iwarp.
> 
> There is also an open source NFS over RDMA implementation for Linux
> available here that: http://sourceforge.net/projects/nfs-rdma.
> 
> 
> So how do we avoid the TOE pitfalls with iWARP? I think it depends on
> the pitfall. At the low level:
> 
> - Stale Network/Address Information: Path MTU Change, ICMP Redirect 
> and ARP next hop changes need netlink notifier events so that hardware
> can be updated when they change. I see this support as an extension (new
> events) to an existing service and a relatively low-level of "parallel
> stack integration". iSCSI and IB could also benefit from these events.
> 
> - Port Space Collision, i.e. socket app and rdma/iWARP apps collide on 
> a port number: The RDMA CMA needs to be able to allocate and de-allocate
> port numbers, however, the services that do this today are not exported
> and would need some minor tweaking. iSCSI and IB benefit from these
> services as well.
> 
> - netfilter rules, syn-flood, conn-rate, etc.... You pointed out that 
> if connection establishment were done in the native stack (SYN,
> SYN/ACK), that this would account for the bulk of the netfilter utility,
> however, this probably results in falling into many of the TOE traps
> people have issue with.

However, iWARP devices _could_ integrate with netfilter.  For most
devices the connection request event (SYN) gets passed up to the host
driver.  So the driver can enforce filter rules then.  Also, i think a
notification type mechanism could be used to trigger iWARP drivers to go
re-apply filter rules on existing connections and kill ones that should
be filtered.  I'm not that familiar yet with netfilter, but I think this
could all be done...

Steve.


