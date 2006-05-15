From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32.c: modify RX ring size through module parameter
Date: Mon, 15 May 2006 08:54:54 -0700
Message-ID: <20060515155454.GA31478@us.ibm.com>
References: <4467F63E.5060401@tw.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:65164 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751565AbWEOPzI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 11:55:08 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4FFt8xl028182
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 11:55:08 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4FFt7r2266816
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 09:55:07 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k4FFt6DR001780
	for <netdev@vger.kernel.org>; Mon, 15 May 2006 09:55:07 -0600
To: Wen Hsin Chang <whchang@tw.ibm.com>
Content-Disposition: inline
In-Reply-To: <4467F63E.5060401@tw.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have several problems with this patch.  First, it assumes you only have
one device or you want all devices to operate with the same receive ring
size.  (use module_param_array like full_duplex or options).

Second, the mininum number of descriptors should be 4 not 2, or the
loopback test will look past the end of the receive ring looking for
status to change, and then try and pick up an skb pointer past the end of
the array and try to dereference it.

Either fix the loopback test to work with the minimum number of tx and rx
descriptors instead of the hard coded 4, or make the minimum rx ring
size be 4.  numbuffs = min(4 , min(lp->tx_ring_size, lp->rx_ring_size));

Another nit is the description says it is the "RX Ring Buffer Size" which
might be misunderstood as the size of the receive buffer, not the size of
the receive descriptor ring.  ("RX Ring Size" would be better).

Lastly, the patch also will not apply against pcnet32.c in mainline
2.6.17-rc4 due to whitespace changes.

On Mon, May 15, 2006 at 11:32:14AM +0800, Wen Hsin Chang wrote:
> This patch is created from pcnet32.c v1.32. it will allow users to 
> specify RX ring size upon module
> insertion via module parameter 'rx_log_size'. This is needed in some 
> cases where too small the rx ring
> size will cause RX errors upon remote installation via pcnet32 NIC card.
> 
> Signed-off-by: Wen Hsin Chang <whchang@tw.ibm.com>

-- 
Don Fry
brazilnut@us.ibm.com
