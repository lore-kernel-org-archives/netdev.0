From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: Allow setting multicast filter on all macvlan
 types
Date: Sun, 17 Aug 2014 11:43:08 +0200
Message-ID: <20140817094308.GD21143@redhat.com>
References: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jason Wang <jasowang@redhat.com>
To: Vladislav Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbaHQJmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2014 05:42:35 -0400
Content-Disposition: inline
In-Reply-To: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 01:04:59PM -0400, Vladislav Yasevich wrote:
> Currently, macvlan code restricts multicast and unicast
> filter setting only to passthru devices.  As a result,
> if a guest using macvtap wants to receive multicast
> traffic, it has to set IFF_ALLMULTI or IFF_PROMISC.
> 
> This patch makes it possible to use the fdb interface
> to add multicast addresses to the filter thus allowing
> a guest to receive only targeted multicast traffic.
> 
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvlan.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index ef8a5c2..fad4b9e 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -739,7 +739,10 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	int err = -EINVAL;
>  
> -	if (!vlan->port->passthru)
> +	/* Support unicast filter only on passthru devices.
> +	 * Multicast filter should be allowed on all devices.
> +	 */
> +	if (!vlan->port->passthru && is_unicast_ether_addr(addr))
>  		return -EOPNOTSUPP;
>  
>  	if (flags & NLM_F_REPLACE)
> @@ -760,7 +763,10 @@ static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	int err = -EINVAL;
>  
> -	if (!vlan->port->passthru)
> +	/* Support unicast filter only on passthru devices.
> +	 * Multicast filter should be allowed on all devices.
> +	 */
> +	if (!vlan->port->passthru && is_unicast_ether_addr(addr))
>  		return -EOPNOTSUPP;
>  
>  	if (is_unicast_ether_addr(addr))
> -- 
> 1.9.3
