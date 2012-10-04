From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch v3 01/11] netlink: add reference of module in
 netlink_dump_start
Date: Thu, 4 Oct 2012 16:41:42 +0100
Message-ID: <1349365302.2817.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<steffen.klassert@secunet.com>, <netfilter-devel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <pablo@netfilter.org>,
	<stephen.hemminger@vyatta.com>, <jengelh@inai.de>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-04 at 12:41 +0800, Gao feng wrote:
> I get a panic when I use ss -a and rmmod inet_diag at the
> same time.
> 
> it's because netlink_dump use inet_diag_dump witch function
> belongs to module inet_diag.
> 
> I search the codes and find many modules have the same problem.
> We need add reference of the module witch the cb->dump belongs
> to.
> 
> Thanks for all help from Stephen,Jan,Eric,Steffen and Pablo.
> 
> Change From v2:
> 
> delete netlink_dump_done,and call module_put in netlink_dump
> and netlink_sock_destruct.
[...]
> @@ -1794,19 +1798,28 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>  		return -ECONNREFUSED;
>  	}
>  	nlk = nlk_sk(sk);
> -	/* A dump is in progress... */
> +
>  	mutex_lock(nlk->cb_mutex);
> +	/* A dump is in progress... */
>  	if (nlk->cb) {
>  		mutex_unlock(nlk->cb_mutex);
>  		netlink_destroy_callback(cb);
> -		sock_put(sk);
> -		return -EBUSY;
> +		ret = -EBUSY;
> +		goto out;
>  	}
> +	/* add reference of module witch cb->dump belong to */
[...]

'which' not 'witch' :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

