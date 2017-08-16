From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 21/21] net-next/hinic: Add select_queue and
 netpoll
Date: Wed, 16 Aug 2017 11:47:21 -0700 (PDT)
Message-ID: <20170816.114721.2286909258495579175.davem@davemloft.net>
References: <cover.1502883967.git.aviad.krawczyk@huawei.com>
        <d5f45e39dc7d5ccb0bcb6bd5e2ebea7d6ffaba83.1502883967.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: aviad.krawczyk@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d5f45e39dc7d5ccb0bcb6bd5e2ebea7d6ffaba83.1502883967.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Date: Wed, 16 Aug 2017 20:03:06 +0800

> +static u16 hinic_select_queue(struct net_device *netdev, struct sk_buff *skb,
> +			      void *accel_priv,
> +			      select_queue_fallback_t fallback)
> +{
> +	u16 qid;
> +
> +	if (skb_rx_queue_recorded(skb))
> +		qid = skb_get_rx_queue(skb);
> +	else
> +		qid = fallback(netdev, skb);
> +
> +	return qid;
> +}

This is a NOP, do not implement this function unless you absolutely need to
do something custom in your driver, and you do not.
