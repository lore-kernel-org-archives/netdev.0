From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 04/18] stmmac: remove modulo in
 stmmac_xmit()
Date: Mon, 04 Jan 2016 22:34:59 -0500 (EST)
Message-ID: <20160104.223459.1663440859688328335.davem@davemloft.net>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
	<1451912823-5245-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com, david.mckay@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbcAEDfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:35:01 -0500
In-Reply-To: <1451912823-5245-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 4 Jan 2016 14:06:49 +0100

> @@ -2056,7 +2068,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  	priv->hw->desc->set_tx_owner(first);
>  	wmb();
>  
> -	priv->cur_tx++;
> +	if (++entry >= txsize)
> +		entry = 0;

You are doing this over and over again, encapsulate it into a helper
like "NEXT_TX(x)" or similar.

Also, this is just fundamentally completely stupid.  Enforce the ring
size to be a power-of-2, then you can just go "x + 1 & (size - 1)" and
not even have the conditional statement.

Thanks.
