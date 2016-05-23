From: Ben Greear <greearb@candelatech.com>
Subject: pktgen issue with "Observe needed_headroom of the device"
Date: Mon, 23 May 2016 12:44:56 -0700
Message-ID: <57435DB8.6090807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, bogdan.hamciuc@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:53689 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbcEWTo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 15:44:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regarding this commit:

879c7220e828af8bd82ea9d774c7e45c46b976e4

net: pktgen: Observe needed_headroom of the device

     Allocate enough space so as not to force the outgoing net device to do
     skb_realloc_headroom().

     Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>


I think it may be incorrect.  It seems that pkt_overhead is meant to be
the data-portion of the skb, not lower-level padding?

For instance:

	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
...

	/* Eth + IPh + UDPh + mpls */
	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
		  pkt_dev->pkt_overhead;

So, maybe we need to add that LL_RESERVED_SPACE to the size when allocating
the skb in pktgen_alloc_skb and leave it out of pkt_overhead?

And for that matter, what is that '+ 64 +' for in the size calculation?
Looks a lot like some fudge factor from long ago?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
