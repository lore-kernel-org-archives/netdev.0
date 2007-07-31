From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP traffic
Date: Mon, 30 Jul 2007 23:58:07 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701F7A5DB@nekter>
References: <200707301724.33865.ossthema@de.ibm.com> <20070730170038.GA4884@austin.ibm.com> <46AE232F.3080409@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"netdev" <netdev@vger.kernel.org>,
	"Thomas Klein" <tklein@de.ibm.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Marcus Eder" <meder@de.ibm.com>,
	"Stefan Roscher" <stefan.roscher@de.ibm.com>,
	"David Miller" <davem@davemloft.net>
To: "Andrew Gallatin" <gallatin@myri.com>,
	"Linas Vepstas" <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:19351 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbXGaEND convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 00:13:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46AE232F.3080409@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Andrew Gallatin
> Sent: Monday, July 30, 2007 10:43 AM
> To: Linas Vepstas
> Cc: Jan-Bernd Themann; netdev; Thomas Klein; Jeff Garzik; Jan-Bernd
> Themann; linux-kernel; linux-ppc; Christoph Raisch; Marcus Eder;
Stefan
> Roscher; David Miller
> Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for
> TCP traffic
> 
> 
> Here is a quick reply before something more official can
> be written up:
> 
> Linas Vepstas wrote:
> 
>  > -- what is LRO?
> 
> Large Receive Offload
> 
>  > -- Basic principles of operation?
> 
> LRO is analogous to a receive side version of TSO.  The NIC (or
> driver) merges several consecutive segments from the same connection,
> fixing up checksums, etc.  Rather than up to 45 separate 1500 byte
> frames (meaning up to 45 trips through the network stack), the driver
> merges them into one 65212 byte frame.  It currently works only
> with TCP over IPv4.
> 
> LRO was, AFAIK, first though of by Neterion.  They had a paper about
> it at OLS2005.
> http://www.linuxinsight.com/files/ols2005/grossman-reprint.pdf
> 
>  > -- Can I use it in my driver?
> 
> Yes, it can be used in any driver.
> 
>  > -- Does my hardware have to have some special feature before I can
> use it?
> 
> No.

Ditto. LRO hw assists (or full LRO offload, meaning that the merge
happens in the ASIC but the merge criteria are set by the host) are
quite beneficial, especially as the number of LRO connections gets very
large (Neterion has IP around fw/hw LRO and will release full hw LRO
offload in the next ASIC), but as Andrew indicated sw-only LRO
implementation can be done for any NIC and provides good results -
especially for non-jumbo workloads. 

> 
>  > -- What sort of performance improvement does it provide?
Throughput?
>  >    Latency? CPU usage? How does it affect DMA allocation? Does it
>  >    improve only a certain type of traffic (large/small packets,
> etc.)
> 
> The benefit is directly proportional to the packet rate.
> 
> See my reply to the previous RFC for performance information.  The
> executive summary is that for the myri10ge 10GbE driver on low end
> hardware with 1500b frames, I've seen it increase throughput by a
> factor of nearly 2.5x, while at the same time reducing CPU utilization
> by 17%.  The affect for jumbo frames is less dramatic, but still
> impressive (1.10x, 14% CPU reduction)
> 
> You can achieve better speedups if your driver receives into
> high-order pages.
> 
>  > -- Example code? What's the API? How should my driver use it?
> 
> The 3/4 in this patch showed an example of converting a driver
> to use LRO for skb based receive buffers.   I'm working on
> a patch for myri10ge that shows how you would use it in a driver
> which receives into pages.
> 
> Cheers,
> 
> Drew
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
