From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] virtio_net: VIRTIO_NET_F_MSG_RXBUF (imprive rcv
 buffer allocation)
Date: Sun, 16 Nov 2008 22:42:19 -0800 (PST)
Message-ID: <20081116.224219.248376635.davem@davemloft.net>
References: <200811171344.57410.rusty@rustcorp.com.au>
	<200811171346.09039.rusty@rustcorp.com.au>
	<200811171347.42694.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com,
	herbert@gondor.apana.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752949AbYKQGmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:42:19 -0500
In-Reply-To: <200811171347.42694.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 17 Nov 2008 13:47:42 +1030

> If segmentation offload is enabled by the host, we currently allocate
> maximum sized packet buffers and pass them to the host. This uses up
> 20 ring entries, allowing us to supply only 20 packet buffers to the
> host with a 256 entry ring. This is a huge overhead when receiving
> small packets, and is most keenly felt when receiving MTU sized
> packets from off-host.
> 
> The VIRTIO_NET_F_MRG_RXBUF feature flag is set by hosts which support
> using receive buffers which are smaller than the maximum packet size.
> In order to transfer large packets to the guest, the host merges
> together multiple receive buffers to form a larger logical buffer.
> The number of merged buffers is returned to the guest via a field in
> the virtio_net_hdr.
> 
> Make use of this support by supplying single page receive buffers to
> the host. On receive, we extract the virtio_net_hdr, copy 128 bytes of
> the payload to the skb's linear data buffer and adjust the fragment
> offset to point to the remaining data. This ensures proper alignment
> and allows us to not use any paged data for small packets. If the
> payload occupies multiple pages, we simply append those pages as
> fragments and free the associated skbs.
> 
> This scheme allows us to be efficient in our use of ring entries
> while still supporting large packets. Benchmarking using netperf from
> an external machine to a guest over a 10Gb/s network shows a 100%
> improvement from ~1Gb/s to ~2Gb/s. With a local host->guest benchmark
> with GSO disabled on the host side, throughput was seen to increase
> from 700Mb/s to 1.7Gb/s.
> 
> Based on a patch from Herbert Xu.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (use netdev_priv)

Applied, but a lot of fuzz and differences when adding to net-next-2.6
