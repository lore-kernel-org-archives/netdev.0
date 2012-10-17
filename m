From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: igb mtu change
Date: Wed, 17 Oct 2012 13:09:46 -0700
Message-ID: <507F108A.3080308@intel.com>
References: <CAGZFCEHACn8e99vL3hA_ErvmQ=5E4dfEbO7TjEU=92eeUUT7UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:28918 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756303Ab2JQUJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 16:09:47 -0400
In-Reply-To: <CAGZFCEHACn8e99vL3hA_ErvmQ=5E4dfEbO7TjEU=92eeUUT7UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2012 07:41 AM, ratheesh kannoth wrote:
> igb_change_mtu change is only changing adapter->rx_ring[0]->rx_buffer_len.
>
> 1)  we dont have to change adapter->tx_ring[0]->rx_buffer_len ?
> 2) Is there any way to set different values to
> adapter->tx_ring[0]->rx_buffer_len and
> adapter->rx_ring[0]->rx_buffer_len ?
>
> I am facing a problem because i have a strange requirement....i have
> 2KB  bufffer pools ( GFP_DMA ) in kernel.
> When i receive a jumbo pkt of size 9126,     five rx_desc should be
> used to recieve paket. So the first rx_desc will have a status error
> bit indicating that it is not
> EOP ( eop ) ....I could easily keep track of my 2KB buffer pools.
>
> But when sending ...i wll collect all  2KB buffers of same jumbo frame
> and dma to tx_ring....
> So i need  1500  on rx_ring[0]->rx_buffer_len and  9126 on
> adapter->tx_ring[0]->rx_buffer_len. .Is there any way ?
>
> Thanks,
> Ratheesh
What version of the igb driver are you using?  What you are describing
doesn't sound like the behaviour of the current igb driver.

The current igb driver does receive the frame data into 2K buffers, and
transmits up to MTU size.  The only limitation on the size of the frame
you can transmit is the netdev->mtu which the driver doesn't evaluate. 
It is evaluated at the network stack level.  The igb driver can send up
to 9K frames, in addition it can TSO up to 64K frames and send them in
9K chunks so I am not sure what you are asking.

Thanks,

Alex
