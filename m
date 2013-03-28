From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] Crash with NULL pointer dereference in bond_handle_frame
 in -rt (possibly mainline)
Date: Thu, 28 Mar 2013 13:44:06 -0400
Message-ID: <1364492646.10629.1.camel@gandalf.local.home>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364491792.15753.47.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-28 at 10:29 -0700, Eric Dumazet wrote:

> Nothing :(
> 
> bug introduced in commit 35d48903e9781975e823b359ee85c257c9ff5c1c
> (bonding: fix rx_handler locking)
> 
> CC Jiri
> 
> Fix seems simple :
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6bbd90e..7956ca5 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1457,6 +1457,8 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  	*pskb = skb;
>  
>  	slave = bond_slave_get_rcu(skb->dev);
> +	if (!slave)
> +		return ret;

Thanks! That's basically what I thought, but wanted to make sure there's
wasn't some other synchronization that I may have been missing.

-- Steve

>  	bond = slave->bond;
>  
>  	if (bond->params.arp_interval)
> 
> 
