From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCHv2 net 4/4] qlcnic: Implement ndo_gso_check()
Date: Fri, 14 Nov 2014 05:08:40 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A470A126E@avmb2.qlogic.org>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
 <1415925495-59312-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sathya.perla@emulex.com" <sathya.perla@emulex.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	"Tom Herbert (Partner - google)" <therbert@google.com>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415925495-59312-5-git-send-email-joestringer@nicira.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Stringer [mailto:joestringer@nicira.com]
> Sent: Friday, November 14, 2014 6:08 AM
> To: netdev
> Cc: sathya.perla@emulex.com; Shahed Shaikh; amirv@mellanox.com; Dept-
> GE Linux NIC Dev; Tom Herbert (Partner - google); gerlitz.or@gmail.com;
> alexander.duyck@gmail.com; linux-kernel
> Subject: [PATCHv2 net 4/4] qlcnic: Implement ndo_gso_check()
> 
> Use vxlan_gso_check() to advertise offload support for this NIC.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Refactor out vxlan helper.
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 ++++++
>  1 file changed, 6 insertions(+)

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks Joe.

-Shahed
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index f5e29f7..a913b3a 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -503,6 +503,11 @@ static void qlcnic_del_vxlan_port(struct net_device
> *netdev,
> 
>  	adapter->flags |= QLCNIC_DEL_VXLAN_PORT;  }
> +
> +static bool qlcnic_gso_check(struct sk_buff *skb, struct net_device
> +*dev) {
> +	return vxlan_gso_check(skb);
> +}
>  #endif
> 
>  static const struct net_device_ops qlcnic_netdev_ops = { @@ -526,6 +531,7
> @@ static const struct net_device_ops qlcnic_netdev_ops = {  #ifdef
> CONFIG_QLCNIC_VXLAN
>  	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
>  	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
> +	.ndo_gso_check		= qlcnic_gso_check,
>  #endif
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = qlcnic_poll_controller,
> --
> 1.7.10.4
