From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Use csum_start offset instead of skb_transport_header
Date: Mon, 09 Apr 2007 11:59:21 -0700 (PDT)
Message-ID: <20070409.115921.45202402.davem@davemloft.net>
References: <20070404020530.GA30050@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932263AbXDIS7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:59:21 -0400
In-Reply-To: <20070404020530.GA30050@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 4 Apr 2007 12:05:30 +1000

> Hi Dave:
> 
> I've finally managed to kill the Xen csum_blank/proto_data_valid hack.
> In the process I needed to make two more changes to Linux.  Here are
> the patches against net-2.6.22.
> 
> [NET]: Use csum_start offset instead of skb_transport_header
> 
> The skb transport pointer is currently used to specify the start
> of the checksum region for transmit checksum offload.  Unfortunately,
> the same pointer is also used during receive side processing.
> 
> This creates a problem when we want to retransmit a received
> packet with partial checksums since the skb transport pointer
> would be overwritten.
> 
> This patch solves this problem by creating a new 16-bit csum_start
> offset value to replace the skb transport header for the purpose
> of checksums.  This offset is calculated from skb->head so that
> it does not have to change when skb->data changes.
> 
> No extra space is required since csum_offset itself fits within
> a 16-bit word so we can use the other 16 bits for csum_start.
> 
> For backwards compatibility, just before we push a packet with
> partial checksums off into the device driver, we set the skb
> transport header to what it would have been under the old scheme.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, nice work Herbert.
