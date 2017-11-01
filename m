From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: Use common error handling code in vxcan_newlink()
Date: Wed, 1 Nov 2017 20:09:31 +0100
Message-ID: <08fd31d5-8677-81e7-65d6-40d501017db6@hartkopp.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <23fbbdba-fb11-a6bc-7d6a-4af43ef79503@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        linux-can@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <23fbbdba-fb11-a6bc-7d6a-4af43ef79503@users.sourceforge.net>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/01/2017 03:16 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 1 Nov 2017 14:56:15 +0100
> 
> Add a jump target so that a bit of exception handling can be better reused
> at the end of this function.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Again: Posting such a patch on linux-can@vger.kernel.org is ENOUGH!

No need to cross post such a patch additionally on

netdev@vger.kernel.org
linux-kernel@vger.kernel.org
kernel-janitors@vger.kernel.org

and to each of the maintainers

mkl@pengutronix.de
wg@grandegger.com
socketcan@hartkopp.net

We all subscribed the mailing list and listen to it.
That's the intention of a mailing list ...

Cross posting is not appreciated in the community.

Thanks,
Oliver

> ---
> 
> v2:
> An approach to make two checks for a failure predicate a bit safer
> was rejected on 2017-10-28.
> The possibility remains to reconsider such an adjustment later again.
> https://lkml.org/lkml/2017/10/28/125
> https://lkml.kernel.org/r/<264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
> 
>   drivers/net/can/vxcan.c | 16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/can/vxcan.c b/drivers/net/can/vxcan.c
> index 8404e8852a0f..5d1753cfacea 100644
> --- a/drivers/net/can/vxcan.c
> +++ b/drivers/net/can/vxcan.c
> @@ -227,10 +227,8 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   	netif_carrier_off(peer);
>   
>   	err = rtnl_configure_link(peer, ifmp);
> -	if (err < 0) {
> -		unregister_netdevice(peer);
> -		return err;
> -	}
> +	if (err < 0)
> +		goto unregister_network_device;
>   
>   	/* register first device */
>   	if (tb[IFLA_IFNAME])
> @@ -239,10 +237,8 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   		snprintf(dev->name, IFNAMSIZ, DRV_NAME "%%d");
>   
>   	err = register_netdevice(dev);
> -	if (err < 0) {
> -		unregister_netdevice(peer);
> -		return err;
> -	}
> +	if (err < 0)
> +		goto unregister_network_device;
>   
>   	netif_carrier_off(dev);
>   
> @@ -254,6 +250,10 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>   	rcu_assign_pointer(priv->peer, dev);
>   
>   	return 0;
> +
> +unregister_network_device:
> +	unregister_netdevice(peer);
> +	return err;
>   }
>   
>   static void vxcan_dellink(struct net_device *dev, struct list_head *head)
> 
