From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: igb mtu change
Date: Wed, 17 Oct 2012 20:11:09 +0530
Message-ID: <CAGZFCEHACn8e99vL3hA_ErvmQ=5E4dfEbO7TjEU=92eeUUT7UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: e1000-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47656 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757287Ab2JQOlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 10:41:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb_change_mtu change is only changing adapter->rx_ring[0]->rx_buffer_len.

1)  we dont have to change adapter->tx_ring[0]->rx_buffer_len ?
2) Is there any way to set different values to
adapter->tx_ring[0]->rx_buffer_len and
adapter->rx_ring[0]->rx_buffer_len ?

I am facing a problem because i have a strange requirement....i have
2KB  bufffer pools ( GFP_DMA ) in kernel.
When i receive a jumbo pkt of size 9126,     five rx_desc should be
used to recieve paket. So the first rx_desc will have a status error
bit indicating that it is not
EOP ( eop ) ....I could easily keep track of my 2KB buffer pools.

But when sending ...i wll collect all  2KB buffers of same jumbo frame
and dma to tx_ring....
So i need  1500  on rx_ring[0]->rx_buffer_len and  9126 on
adapter->tx_ring[0]->rx_buffer_len. .Is there any way ?

Thanks,
Ratheesh
