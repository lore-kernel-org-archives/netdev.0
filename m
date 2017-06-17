From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 17 Jun 2017 21:45:38 +0200
Message-ID: <20170617194538.GD1974@lunn.ch>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-3-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void hnae3_list_add(spinlock_t *lock, struct list_head *node,
> +			   struct list_head *head)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(lock, flags);
> +	list_add_tail(node, head);
> +	spin_unlock_irqrestore(lock, flags);
> +}
> +
> +static void hnae3_list_del(spinlock_t *lock, struct list_head *node)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(lock, flags);
> +	list_del(node);
> +	spin_unlock_irqrestore(lock, flags);
> +}
> +

> +int hnae3_register_client(struct hnae3_client *client)
> +{
> +	struct hnae3_client *client_tmp;
> +	struct hnae3_ae_dev *ae_dev;
> +	int ret;
> +
> +	/* One system should only have one client for every type */
> +	list_for_each_entry(client_tmp, &hnae3_client_list, node) {
> +		if (client_tmp->type == client->type)
> +			return 0;
> +	}
> +
> +	hnae3_list_add(&hnae3_list_client_lock, &client->node,
> +		       &hnae3_client_list);

Please could you explain your locking scheme. I don't get it.

       Thanks
	Andrew
