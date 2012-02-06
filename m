From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/5] netdev: ethernet dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 06 Feb 2012 11:45:05 -0500 (EST)
Message-ID: <20120206.114505.1068389709235471266.davem@davemloft.net>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Date: Sun,  5 Feb 2012 18:19:09 +0530

> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> 
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>   - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied, but I had to fix several things up:

> -			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
> +			if (pkt_len < rx_copybreak &&
> +					(skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {

This is not the correct way to format a multi-line conditional.

All subsequent lines must start at the first column after the initial line's
openning parenthesis:

	if (format_it &&
	    like_this)

	if (not &&
		like_this)

To be honest I have no idea what posses people to tab things out in such
an incredibly ugly fashion in the first place.

> -		if (!(lp->rx_skbuff[i] = dev_alloc_skb(lp->rx_buff_len))) {
> +		lp->rx_skbuff[i] = netdev_alloc_skb(dev, lp->rx_buff_len);
> +		if (!lp->rx_skbuff[i]) {

You properly leave this test alone and keep it as "!foo" yet:

> -			if(!(new_skb = dev_alloc_skb(lp->rx_buff_len))){
> +			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
> +			if (new_skb == NULL) {

You change this one to the undesirable "== NULL" test, don't do that.
"!foo" is the canonical and most efficient NULL pointer test.

> -      skb = dev_alloc_skb(pkt_len+2);
> +	skb = netdev_alloc_skb(dev, pkt_len + 2);

Do not change the indentation in one place when the entire rest of the source
file uses something else, fixing that would a seperate change from what you're
doing.

> -	    skb = dev_alloc_skb(RX_BUFLEN + 2);
> +		skb = netdev_alloc_skb(RX_BUFLEN + 2);

Same problem.
