From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 17:41:39 -0500
Message-ID: <423764A3.8030201@pobox.com>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: akpm@osdl.org
In-Reply-To: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Christoph Lameter <christoph@graphe.net>
> 
> The last_rx field in the loopback driver is updated on every xmit but is
> not used otherwise.  Accesses to ->last_rx cause unecessary traffic on the
> interlink for NUMA systems which limits the performance of the loopback
> device.
> 
> The comment given at include/linux/netdevice.h says that last_rx may be
> used for future network-power-down code, which is likely not relevant for
> the loopback device (please let me know if it is otherwise ..).
> 
> Signed-off-by: Niraj Kumar <nirajk@calsoftinc.com>
> Signed-off-by: Christoph Lameter <christoph@lameter.com>
> Signed-off-by: Shai Fultheim <Shai@Scalex86.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  25-akpm/drivers/net/loopback.c |    2 --
>  1 files changed, 2 deletions(-)
> 
> diff -puN drivers/net/loopback.c~remove-last_rx-update-from-loopback-device drivers/net/loopback.c
> --- 25/drivers/net/loopback.c~remove-last_rx-update-from-loopback-device	Tue Mar 15 14:19:53 2005
> +++ 25-akpm/drivers/net/loopback.c	Tue Mar 15 14:19:53 2005
> @@ -144,8 +144,6 @@ static int loopback_xmit(struct sk_buff 
>  		return 0;
>  	}
>  
> -	dev->last_rx = jiffies;
> -
>  	lb_stats = &per_cpu(loopback_stats, get_cpu());
>  	lb_stats->rx_bytes += skb->len;
>  	lb_stats->tx_bytes += skb->len;

I disagree.  loopback.c is doing precisely what it should be doing.

	Jeff
