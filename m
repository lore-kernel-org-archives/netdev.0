From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Mon, 02 Jan 2017 19:30:03 -0500 (EST)
Message-ID: <20170102.193003.577100357837775083.davem@davemloft.net>
References: <20170102233410.4070-1-wr0112358@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: wr0112358@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102233410.4070-1-wr0112358@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Reiter Wolfgang <wr0112358@gmail.com>
Date: Tue,  3 Jan 2017 00:34:10 +0100

> Final nlmsg_len field update must reflect inserted net_dm_drop_point
> data.
> 
> This patch depends on previous patch:
> "drop_monitor: add missing call to genlmsg_end"
> 
> Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>

Several coding style errors:

> @@ -112,6 +111,12 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
>  	swap(data->skb, skb);
>  	spin_unlock_irqrestore(&data->lock, flags);
>  
> +	if(skb) {

There must be a space between "if" and "(skb)"

> +		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
> +		struct genlmsghdr *gnlh = (struct genlmsghdr *)nlmsg_data(nlh);
> +		genlmsg_end(skb, genlmsg_data(gnlh));
> +	}

There should be an empty line between the local variable declarations
and actual code.
