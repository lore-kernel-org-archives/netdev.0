From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom the host TCP port space.
Date: Mon, 20 Aug 2007 09:26:31 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E2108@maui.asicdesigners.com>
References: <8A71B368A89016469F72CD08050AD334018E20BC@maui.asicdesigners.com><20070819.174017.77241227.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com><20070819.180540.74750322.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E20C1@maui.asicdesigners.com> <p733aye1n39.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <sean.hefty@intel.com>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<general@lists.openfabrics.org>, <linux-kernel@vger.kernel.org>,
	<jeff@garzik.org>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:17031 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbXHTQ3W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:29:22 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: ak@suse.de [mailto:ak@suse.de] On Behalf Of Andi Kleen
> Sent: Monday, August 20, 2007 4:07 AM
> To: Felix Marti
> Cc: David Miller; sean.hefty@intel.com; netdev@vger.kernel.org;
> rdreier@cisco.com; general@lists.openfabrics.org; linux-
> kernel@vger.kernel.org; jeff@garzik.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
> 
> "Felix Marti" <felix@chelsio.com> writes:
> > > avoidance gains of TSO and LRO are still a very worthwhile
savings.
> > So, i.e. with TSO, your saving about 16 headers (let us say 14 + 20
+
> > 20), 864B, when moving ~64KB of payload - looks like very much in
the
> > noise to me.
> 
> TSO is beneficial for the software again. The linux code currently
> takes several locks and does quite a few function calls for each
> packet and using larger packets lowers this overhead. At least with
> 10GbE saving CPU cycles is still quite important.
> 
> > an option to get 'high performance'
> 
> Shouldn't you qualify that?
> 
> It is unlikely you really duplicated all the tuning for corner cases
> that went over many years into good software TCP stacks in your
> hardware.  So e.g. for wide area networks with occasional packet loss
> the software might well perform better.
Yes, it used to be sufficient to submit performance data to show that a
technology make 'sense'. In fact, I believe it was Alan Cox who once
said that linux will have a look at offload once an offload device holds
the land speed record (probably assuming that the day never comes ;).
For the last few years it has been Chelsio offload devices that have
been improving their own LSRs (as IO bus speeds have been increasing).
It is worthwhile to point out that OC-192 doesn't offer full 10Gbps BW
and the fine-grained (per packet and not per TSO-burst) packet scheduler
in the offload device played a crucial part in pushing performance to
the limits of what OC-192 can do. Most other customers use our offload
products in low-latency cluster environments. - The problem with offload
devices is that they are not all born equal and there have been a lot of
poor implementation giving the technology a bad name. I can only speak
for Chelsio and do claim that we have a solid implementation that scales
from low-latency clusters environments to LFNs.

Andi, I could present performance numbers, i.e. throughput and CPU
utilization in function of IO size, number of connections, ... in a
back-to-back environment and/or in a cluster environment... but what
will it get me? I'd still get hit by the 'not integrated' hammer :(

> 
> -Andi
