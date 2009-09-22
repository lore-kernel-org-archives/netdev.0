From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] skb align patch
Date: Mon, 21 Sep 2009 22:29:40 -0700 (PDT)
Message-ID: <20090921.222940.258576265.davem@davemloft.net>
References: <4AB71980.4020208@gmail.com>
	<20090921213011.704e0594@nehalam>
	<4AB84295.3050509@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jesse.brandeburg@gmail.com, hawk@diku.dk,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753564AbZIVF3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:29:22 -0400
In-Reply-To: <4AB84295.3050509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Sep 2009 05:20:53 +0200

> Oh I see, you want to optimize the rx (NIC has to do a DMA to write
> packet into host memory and this DMA could be a read /modify/write
> if address is not aligned, instead of a pure write), while I tried
> to align skb to optimize the pktgen tx (NIC has to do a DMA to read
> packet from host), and align the skb had no effect.

This is a problem with these kinds of changes.

This patch from Stephen came out of a presentation and discussion
at netconf where the Intel folks showed that if they did a combination
of things it improved NUMA forwarding numbers a lot.

So you couldn't just do NUMA spreading of RX queue memory, or just
do this ALIGN patch, or just eliminate the false sharing from
statistics updates.

You had to do all three to start seeing forwarding rates go up.

So don't worry, this is getting us somewhere to where improvement
shows, but individually each change won't trigger it.

The alignment in this patch is a real big deal for 64 byte forwarding
tests, where the entire packet is a whole PCI-E cacheline.  But not
if it isn't aligned properly.
