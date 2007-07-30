From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP traffic
Date: Mon, 30 Jul 2007 12:00:40 -0500
Message-ID: <20070730170038.GA4884@austin.ibm.com>
References: <200707301724.33865.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Thomas Klein <tklein@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:53117 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933851AbXG3RAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 13:00:42 -0400
Content-Disposition: inline
In-Reply-To: <200707301724.33865.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 30, 2007 at 05:24:33PM +0200, Jan-Bernd Themann wrote:
> 
> Changes to http://www.spinics.net/lists/netdev/msg36912.html
> 
> 1) A new field called "features" has been added to the net_lro_mgr struct.
>    It is set by the driver to indicate:
>    - LRO_F_NAPI:            Use NAPI / netif_rx to pass packets to stack
> 
>    - LRO_F_EXTRACT_VLAN_ID: Set by driver if HW extracts VLAN IDs for VLAN
>         packets but does not modify ETH protocol (ETH_P_8021Q)
> 
> 2) Padded frames are not aggregated for now. Bug fixed
> 
> 3) Correct header length now used. No minimal header length for aggregated
>    packets used anymore.
> 
> 4) Statistic counters were introduced. They are stored in a new struct in
>    the net_lro_mgr. This has the advantage that no locking is required in
>    cases where the driver uses multiple lro_mgrs for different receive queues.
>    Thus we get the following statistics per lro_mgr / eth device:
>    - Number of aggregated packets
>    - Number of flushed packets
>    - Number of times we run out of lro_desc.
> 
>    The ratio of "aggregated packets" and "flushed packets" give you an
>    idea how well LRO is working.

I'd like to see an edited form of this, together with an introduction to
LRO, written up in the Documentation subdirectory.  

As someone with some driver experience, but not on te bleeding edge,
some basc newbie questions pop into mind:

-- what is LRO?
-- Basic principles of operation?
-- Can I use it in my driver?  
-- Does my hardware have to have some special feature before I can use it?
-- What sort of performance improvement does it provide? Throughput?
   Latency? CPU usage? How does it affect DMA allocation? Does it 
   improve only a certain type of traffic (large/small packets, etc.)
-- Example code? What's the API? How should my driver use it?

Right now, I can maybe find answers by doing lots of googling.  I'd like
to have some quick way of getting a grip on this.

--linas
   
