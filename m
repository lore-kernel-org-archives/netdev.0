From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH linux-next 3/4] macvlan: fix possible NULL pointer
 dereference in macvlan_dev_get_iflink
Date: Tue, 14 Apr 2015 16:26:27 +0100
Message-ID: <20150414152626.GJ7874@acer.localdomain>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
 <1429024817-21561-4-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, alex.estrin@intel.com, dledford@redhat.com,
	edumazet@google.com, erezsh@mellanox.com,
	nicolas.dichtel@6wind.com, maheshb@google.com, jbenc@redhat.com,
	ebiederm@xmission.com, elfring@users.sourceforge.net,
	f.fainelli@gmail.com, linux@roeck-us.net, andrew@lunn.ch,
	sfeldma@gmail.com, alexander.h.duyck@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Honggang Li <honli@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47823 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbbDNP0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:26:36 -0400
Content-Disposition: inline
In-Reply-To: <1429024817-21561-4-git-send-email-honli@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.04, Honggang Li wrote:
> Signed-off-by: Honggang Li <honli@redhat.com>
> ---
>  drivers/net/macvlan.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index b227a13..1e59f39 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -998,7 +998,9 @@ static int macvlan_dev_get_iflink(const struct net_device *dev)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  
> -	return vlan->lowerdev->ifindex;
> +	if (vlan && vlan->lowerdev)
> +		return vlan->lowerdev->ifindex;

That is completely useless. vlan (=netdev_priv) can not be NULL as
netdev_priv() never returns NULL and vlan->lowerdev is always valid
because a macvlan wouldn't make much sense otherwise.
