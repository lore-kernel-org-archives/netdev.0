From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH] bonding: enhance L2 hash helper with packet type
Date: Tue, 15 Jul 2014 15:46:07 +0800
Message-ID: <53C4DC3F.2090903@freescale.com>
References: <1405409966-19935-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0210.outbound.protection.outlook.com ([207.46.163.210]:38315
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751467AbaGOHrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 03:47:00 -0400
In-Reply-To: <1405409966-19935-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/2014 3:39 PM, Xie Jianhua wrote:
> From: Jianhua Xie <jianhua.xie@freescale.com>
>
> Current L2 hash helper calculates destination eth addr and
> source ether addr as L2 hash factors. This patch is adding
> packet type ID field into hash factors, which can help to
> distribute different types of packets like IPv4/IPv6 packets
> to different slave devices while only BOND_XMIT_POLICY_LAYER2
> is applied.
>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: David S. Miller <davem@davemloft.net>
> CC: Pan Jiafei <Jiafei.Pan@freescale.com>
>
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
> ---
>
> v2-changes:
>   Use the appropriate interface skb_header_pointer()
>   to check skb headlen, fragmented packet or not is
>   not distinguished any more.
>
>
>   drivers/net/bonding/bond_main.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3a451b6..bcff90c 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2999,11 +2999,11 @@ static struct notifier_block bond_netdev_notifier = {
>   /* L2 hash helper */
>   static inline u32 bond_eth_hash(struct sk_buff *skb)
>   {
> -	struct ethhdr *data = (struct ethhdr *)skb->data;
> -
> -	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
> -		return data->h_dest[5] ^ data->h_source[5];
> +	struct ethhdr *ep, hdr_tmp;
>   
> +	ep = skb_header_pointer(skb, 0, sizeof(hdr_tmp), &hdr_tmp);
> +	if (ep)
> +		return ep->h_dest[5] ^ ep->h_source[5] ^ ep->h_proto;
>   	return 0;
>   }
>   
sorry, please ignore it.

Best Regards,
Jianhua
