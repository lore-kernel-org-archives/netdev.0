From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 9/9] ldmvsw: disable tso and gso for bridge
 operations
Date: Fri, 03 Feb 2017 09:59:30 -0800
Message-ID: <1486144770.21871.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
         <1486143755-192532-10-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1486143755-192532-10-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-02-03 at 09:42 -0800, Shannon Nelson wrote:
> The ldmvsw driver is specifically for supporting the ldom virtual
> networking by running in the primary ldom and using the LDC to connect
> the remaining ldoms to the outside world via a bridge.  With TSO and GSO
> supported while connected the bridge, things tend to misbehave as seen in
> our case by delayed packets, enough to begin triggering retransmits and
> affecting overall throughput.  By turning off advertised support for TSO
> and GSO we restore stable traffic flow through the bridge.
> 
> Orabug: 23293104
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
>  drivers/net/ethernet/sun/ldmvsw.c         |    5 ++---
>  drivers/net/ethernet/sun/sunvnet_common.c |    3 ++-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
> index 552c0a9..bd2cfbc 100644
> --- a/drivers/net/ethernet/sun/ldmvsw.c
> +++ b/drivers/net/ethernet/sun/ldmvsw.c
> @@ -299,8 +299,7 @@ static struct net_device *vsw_alloc_netdev(u8 hwaddr[],
>  	dev->ethtool_ops = &vsw_ethtool_ops;
>  	dev->watchdog_timeo = VSW_TX_TIMEOUT;
>  
> -	dev->hw_features = NETIF_F_TSO | NETIF_F_GSO | NETIF_F_GSO_SOFTWARE |
> -			   NETIF_F_HW_CSUM | NETIF_F_SG;
> +	dev->hw_features = NETIF_F_HW_CSUM;


You also removed NETIF_F_SG



