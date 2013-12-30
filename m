From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH net-next v3 04/19] net: enic: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 13:42:18 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1312301341050.2286@cisco.com>
References: <52C12378.7030801@huawei.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-3.cisco.com ([72.163.197.27]:27732 "EHLO
	bgl-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3L3IVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 03:21:50 -0500
In-Reply-To: <52C12378.7030801@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Dec 2013, Ding Tianhong wrote:

> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
>
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Sujith Sankar <ssujith@cisco.com>
> Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
> Cc: Neel Patel <neepatel@cisco.com>
> Cc: Nishank Trivedi <nistrive@cisco.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
> drivers/net/ethernet/cisco/enic/enic_pp.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
> index 43464f0..e6a8319 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_pp.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
> @@ -162,7 +162,7 @@ static int enic_are_pp_different(struct enic_port_profile *pp1,
> 	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
> 		pp2->instance_uuid, PORT_UUID_MAX) |
> 		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
> -		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
> +		!ether_addr_equal(pp1->mac_addr, pp2->mac_addr);
> }
>
> static int enic_pp_preassociate(struct enic *enic, int vf,
> -- 
> 1.8.0
>

looks good for me

Acked-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
