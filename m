From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/11] sfc: Prefetch RX skb header area
Date: Thu, 20 Jun 2013 00:10:45 +0100
Message-ID: <1371683445.1956.134.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680432.1956.116.camel@bwh-desktop.uk.level5networks.com>
	 <1371681389.3252.339.camel@edumazet-glaptop>
	 <1371681557.1956.121.camel@bwh-desktop.uk.level5networks.com>
	 <1371682581.3252.353.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16766 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934170Ab3FSXKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 19:10:50 -0400
In-Reply-To: <1371682581.3252.353.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 15:56 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 23:39 +0100, Ben Hutchings wrote:
> 
> > You can't use build_skb() if you put multiple RX buffers in a page.  See
> > <1365805319.2791.18.camel@bwh-desktop.uk.solarflarecom.com>.
> 
> Well, you use small skb (used to have 64 bytes headroom and you changed
> it to 128) and attach a frag on it, so anyway build_skb() brings
> nothing.
> 
> I suspect you have a win on workloads with flood of rx, but on moderate
> load sk_buff will be cold, so the cache adds latencies.
> 
> My feeling is that this kind of tradeoff should not be per driver.

Jon's testing showed a significant latency improvement.

In Linux 3.10 sfc has reduced UDP performance (both latency and
throughput) as we removed the support for skb pre-allocation in
preparation for the implementation for DMA scatter and recycling of
IOMMU-mapped buffers.  The RX changes in this series are intended to
recover that, and our benchmark results suggest that we succeeded.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
