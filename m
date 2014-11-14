From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCHv2 net 2/4] be2net: Implement ndo_gso_check()
Date: Fri, 14 Nov 2014 09:43:52 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C68CDD3A1@CMEXMB1.ad.emulex.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
 <1415925495-59312-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shahed.shaikh@qlogic.com" <shahed.shaikh@qlogic.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"Dept-GELinuxNICDev@qlogic.com" <Dept-GELinuxNICDev@qlogic.com>,
	"therbert@google.com" <therbert@google.com>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415925495-59312-3-git-send-email-joestringer@nicira.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Stringer [mailto:joestringer@nicira.com]
> 
> Use vxlan_gso_check() to advertise offload support for this NIC.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Sathya Perla <sperla@emulex.com>

Thanks!

> ---
> v2: Refactor out vxlan helper.
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 9a18e79..3e8475c 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -4421,6 +4421,11 @@ static void be_del_vxlan_port(struct net_device
> *netdev, sa_family_t sa_family,
>  		 "Disabled VxLAN offloads for UDP port %d\n",
>  		 be16_to_cpu(port));
>  }
> +
> +static bool be_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +	return vxlan_gso_check(skb);
> +}
>  #endif
> 
>  static const struct net_device_ops be_netdev_ops = {
> @@ -4450,6 +4455,7 @@ static const struct net_device_ops be_netdev_ops
> = {
>  #ifdef CONFIG_BE2NET_VXLAN
>  	.ndo_add_vxlan_port	= be_add_vxlan_port,
>  	.ndo_del_vxlan_port	= be_del_vxlan_port,
> +	.ndo_gso_check		= be_gso_check,
>  #endif
>  };
> 
> --
> 1.7.10.4
