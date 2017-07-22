From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 22 Jul 2017 23:30:11 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CC25@FRAEML521-MBX.china.huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-3-salil.mehta@huawei.com>
 <20170617194538.GD1974@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170617194538.GD1974@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Saturday, June 17, 2017 8:46 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> > +static void hnae3_list_add(spinlock_t *lock, struct list_head *node,
> > +			   struct list_head *head)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(lock, flags);
> > +	list_add_tail(node, head);
> > +	spin_unlock_irqrestore(lock, flags);
> > +}
> > +
> > +static void hnae3_list_del(spinlock_t *lock, struct list_head *node)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(lock, flags);
> > +	list_del(node);
> > +	spin_unlock_irqrestore(lock, flags);
> > +}
> > +
> 
> > +int hnae3_register_client(struct hnae3_client *client)
> > +{
> > +	struct hnae3_client *client_tmp;
> > +	struct hnae3_ae_dev *ae_dev;
> > +	int ret;
> > +
> > +	/* One system should only have one client for every type */
> > +	list_for_each_entry(client_tmp, &hnae3_client_list, node) {
> > +		if (client_tmp->type == client->type)
> > +			return 0;
> > +	}
> > +
> > +	hnae3_list_add(&hnae3_list_client_lock, &client->node,
> > +		       &hnae3_client_list);
> 
> Please could you explain your locking scheme. I don't get it.
> 
>        Thanks
> 	Andrew
Locking scheme has been fixed in the V4 patch. Please review it.

Thanks
Salil
