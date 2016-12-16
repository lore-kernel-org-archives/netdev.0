From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] encx24j600: bugfix - always move ERXTAIL to next
 packet in encx24j600_rx_packets
Date: Fri, 16 Dec 2016 13:32:08 -0500 (EST)
Message-ID: <20161216.133208.2134512725082545132.davem@davemloft.net>
References: <1481549349-8199-1-git-send-email-jeroen.de_wachter.ext@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jringle@gridpoint.com, akpm@linux-foundation.org,
        netdev@vger.kernel.org
To: jeroen.de_wachter.ext@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932462AbcLPScJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:32:09 -0500
In-Reply-To: <1481549349-8199-1-git-send-email-jeroen.de_wachter.ext@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jeroen.de_wachter.ext@nokia.com>
Date: Mon, 12 Dec 2016 14:29:08 +0100

> From: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>
> 
> Before, encx24j600_rx_packets did not update encx24j600_priv's next_packet
> member when an error occurred during packet handling (either because the
> packet's RSV header indicates an error or because the encx24j600_receive_packet
> method can't allocate an sk_buff).
> 
> If the next_packet member is not updated, the ERXTAIL register will be set to
> the same value it had before, which means the bad packet remains in the
> component's memory and its RSV header will be read again when a new packet
> arrives. If the RSV header indicates a bad packet or if sk_buff allocation
> continues to fail, new packets will be stored in the component's memory until
> that memory is full, after which packets will be dropped.
> 
> The SETPKTDEC command is always executed though, so the encx24j600 hardware has
> an incorrect count of the packets in its memory.
> 
> To prevent this, the next_packet member should always be updated, allowing the
> packet to be skipped (either because it's bad, as indicated in its RSV header,
> or because allocating an sk_buff failed). In the allocation failure case, this
> does mean dropping a valid packet, but dropping the oldest packet to keep as
> much memory as possible available for new packets seems preferable to keeping
> old (but valid) packets around while dropping new ones.
> 
> Signed-off-by: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>

Applied.
