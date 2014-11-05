From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net 5/5] qlcnic: Implement ndo_gso_check()
Date: Wed, 5 Nov 2014 09:17:31 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4709D060@avmb2.qlogic.org>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <1415138202-1197-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sathya.perla@emulex.com" <sathya.perla@emulex.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"linux.nics@intel.com" <linux.nics@intel.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	"Tom Herbert (Partner - google)" <therbert@google.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415138202-1197-6-git-send-email-joestringer@nicira.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Stringer [mailto:joestringer@nicira.com]
> Sent: Wednesday, November 05, 2014 3:27 AM
> To: netdev
> Cc: sathya.perla@emulex.com; jeffrey.t.kirsher@intel.com;
> linux.nics@intel.com; amirv@mellanox.com; Shahed Shaikh; Dept-GE Linux
> NIC Dev; Tom Herbert (Partner - google); linux-kernel
> Subject: [PATCH net 5/5] qlcnic: Implement ndo_gso_check()
> 
> ndo_gso_check() was recently introduced to allow NICs to report the
> offloading support that they have on a per-skb basis. Add an implementation
> for this driver which checks for something that looks like VXLAN.
> 
> Implementation shamelessly stolen from Tom Herbert:
> http://thread.gmane.org/gmane.linux.network/332428/focus=333111
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index f5e29f7..6184f47 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -505,6 +505,17 @@ static void qlcnic_del_vxlan_port(struct net_device
> *netdev,  }  #endif
> 
> +static bool qlcnic_gso_check(struct sk_buff *skb, struct net_device
> +*dev) {
> +	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> +	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +	     skb->inner_protocol != htons(ETH_P_TEB) ||
> +	     skb_inner_mac_header(skb) - skb_transport_header(skb) != 16))
> +		return false;
> +

Hi Joe,

Yes, qlcnic driver only supports VXLAN offload.
It would be good to put a comment about value 16 to make it more intuitive. 
e.g. 16 is the size of outer UDP header + VXLAN header.

Anyway, patch looks good to me.

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
