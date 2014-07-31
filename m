From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 4/5] net-timestamp: TCP timestamping
Date: Thu, 31 Jul 2014 13:41:02 -0700 (PDT)
Message-ID: <20140731.134102.1696108589659772439.davem@davemloft.net>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
	<1406735328-7520-5-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaGaUlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:41:03 -0400
In-Reply-To: <1406735328-7520-5-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 30 Jul 2014 11:48:47 -0400

> TCP timestamping extends SO_TIMESTAMPING to bytestreams.
> 
> Bytestreams do not have a 1:1 relationship between send() buffers and
> network packets. The feature interprets a send call on a bytestream as
> a request for a timestamp for the last byte in that send() buffer.
> 
> The choice corresponds to a request for a timestamp when all bytes in
> the buffer have been sent. That assumption depends on in-order kernel
> transmission. This is the common case. That said, it is possible to
> construct a traffic shaping tree that would result in reordering.
> The guarantee is strong, then, but not ironclad.
> 
> This implementation supports send and sendpages (splice). GSO replaces
> one large packet with multiple smaller packets. This patch also copies
> the option into the correct smaller packet.
> 
> This patch does not yet support timestamping on data in an initial TCP
> Fast Open SYN, because that takes a very different data path.
> 
> The implementation supports a single timestamp per packet. To avoid
> having multiple timestamp requests per sk_buff, the skb is locked
> against extension once the flag is set.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

I'm cautious about a timestamping facility which changes the byte
stream, as this patch does.

Is it possible to define different semantics, in order to avoid this
adverse effect?  For example, only adhere to the first timestamp
request and ignore the rest?

Or perhaps come up with a cheap way to chain them up when coalescing
and expansion occurs.
