From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] packet: uses kfree_skb() for errors.
Date: Wed, 13 Apr 2016 22:56:01 -0400 (EDT)
Message-ID: <20160413.225601.721902514935757078.davem@davemloft.net>
References: <1460132748-23561-1-git-send-email-weongyo.linux@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: weongyo.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbcDNC4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:56:08 -0400
In-Reply-To: <1460132748-23561-1-git-send-email-weongyo.linux@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weongyo Jeong <weongyo.linux@gmail.com>
Date: Fri,  8 Apr 2016 09:25:48 -0700

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1ecfa71..4e054bb 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2042,6 +2042,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
>  	u8 *skb_head = skb->data;
>  	int skb_len = skb->len;
>  	unsigned int snaplen, res;
> +	bool err = false;
>  
>  	if (skb->pkt_type == PACKET_LOOPBACK)
>  		goto drop;

It is non-canonical to use a variable named 'err' as a boolean.
Instead, all programmers expect a variable named 'err' to be an
integer type and to hold an error code.

Therefore please use a more appropriate name for this variable.

Name it in a way which describes the exact important condition
which is true or false.

Thank you.
