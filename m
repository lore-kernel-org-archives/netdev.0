From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Tue, 3 Jan 2017 08:09:25 -0500
Message-ID: <20170103130925.GA11735@hmsreliant.think-freely.org>
References: <20170103003910.8984-1-wr0112358@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Reiter Wolfgang <wr0112358@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57459 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757248AbdACNKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 08:10:24 -0500
Content-Disposition: inline
In-Reply-To: <20170103003910.8984-1-wr0112358@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 01:39:10AM +0100, Reiter Wolfgang wrote:
> Final nlmsg_len field update must reflect inserted net_dm_drop_point
> data.
> 
> This patch depends on previous patch:
> "drop_monitor: add missing call to genlmsg_end"
> 
> Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
> ---
>  net/core/drop_monitor.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index f465bad..fb55327 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -102,7 +102,6 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
>  	}
>  	msg = nla_data(nla);
>  	memset(msg, 0, al);
> -	genlmsg_end(skb, msg_header);
>  	goto out;
>  
>  err:
> @@ -112,6 +111,13 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
>  	swap(data->skb, skb);
>  	spin_unlock_irqrestore(&data->lock, flags);
>  
> +	if (skb) {
> +		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
> +		struct genlmsghdr *gnlh = (struct genlmsghdr *)nlmsg_data(nlh);
> +
> +		genlmsg_end(skb, genlmsg_data(gnlh));
> +	}
> +
>  	return skb;
>  }
>  
> -- 
> 2.9.3
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
