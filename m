From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Tue, 25 Nov 2014 13:42:40 -0500 (EST)
Message-ID: <20141125.134240.861582393401487675.davem@davemloft.net>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
	<1416938286-14147-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaKYSmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:42:42 -0500
In-Reply-To: <1416938286-14147-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 25 Nov 2014 12:58:03 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> When returning timestamped packets on the error queue, only return
> the data that the application initially sent: not the protocol
> headers.
> 
> This changes the ABI. The TCP interface is new enough that it should
> be safe to do so. The UDP interface could be changed analogously with
> 
> +  else if (sk->sk_protocol == IPPROTO_UDP)
> +    skb_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr));
> 
> Tested with Documentation/networking/timestamping/txtimestamp -l 60 -x
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

What's the harm in exposing the headers?  Either it's harmful, and
therefore doing so for UDP is bad too, or it's harmless and we should
probably leave it alone to not risk breaking anyone.
