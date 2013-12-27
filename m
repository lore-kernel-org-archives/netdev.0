From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 02/20] net: bnx2x: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 18:56:18 +0400
Message-ID: <52BD9512.5040105@cogentembedded.com>
References: <52BD22AD.3090702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Ariel Elior <ariele@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BD22AD.3090702@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 27-12-2013 10:48, Ding Tianhong wrote:

> Use the possibly more efficient ether_addr_equal or
> ether_addr_equal_unaligned to instead of memcmp.

> Cc: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    | 10 ++++------
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  2 +-
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |  2 +-
>   3 files changed, 6 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> index 32c92ab..a83c67c 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
[...]
> @@ -696,8 +696,7 @@ static int bnx2x_check_vlan_mac_add(struct bnx2x *bp,
>
>   	list_for_each_entry(pos, &o->head, link)
>   		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
> -		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
> -				  ETH_ALEN)) &&
> +		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&

    Pointless parens around function call again.

> @@ -716,7 +715,7 @@ static struct bnx2x_vlan_mac_registry_elem *
>   	DP(BNX2X_MSG_SP, "Checking MAC %pM for DEL command\n", data->mac.mac);
>
>   	list_for_each_entry(pos, &o->head, link)
> -		if ((!memcmp(data->mac.mac, pos->u.mac.mac, ETH_ALEN)) &&
> +		if ((ether_addr_equal(data->mac.mac, pos->u.mac.mac)) &&

    ... and again.

> @@ -751,8 +750,7 @@ static struct bnx2x_vlan_mac_registry_elem *
>
>   	list_for_each_entry(pos, &o->head, link)
>   		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
> -		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
> -			     ETH_ALEN)) &&
> +		    (ether_addr_equal_unaligned(data->vlan_mac.mac, pos->u.vlan_mac.mac)) &&

    ... and again.

WBR, Sergei
