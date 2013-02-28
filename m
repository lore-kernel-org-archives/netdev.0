From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] generalize VXLAN forwarding tables
Date: Thu, 28 Feb 2013 14:27:55 -0800
Message-ID: <1362090475.15793.51.camel@edumazet-glaptop>
References: <201302281924.r1SJN7u5024149@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34956 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab3B1W15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 17:27:57 -0500
Received: by mail-pa0-f44.google.com with SMTP id kp1so1401611pab.17
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 14:27:57 -0800 (PST)
In-Reply-To: <201302281924.r1SJN7u5024149@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-28 at 14:23 -0500, David L Stevens wrote:

> +	/* if there are multiple destinations, send copies */
> +	for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
> +		struct sk_buff *skb1;
> +
> +		skb1 = skb_clone(skb, GFP_ATOMIC);
> +		rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> +		if (rc == NETDEV_TX_OK)
> +			rc = rc1;
> +	}
> +
> +	rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> +	if (rc == NETDEV_TX_OK)
> +		rc = rc1;
> +	return rc;
> +}


It looks like vxlan_xmit_one() will overwrite header

So skb_clone() is probably not what you wanted ?
