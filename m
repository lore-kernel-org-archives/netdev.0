From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: enhance L2 hash helper with packet type
Date: Mon, 14 Jul 2014 11:15:36 +0200
Message-ID: <1405329336.10255.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: Xie Jianhua <Jianhua.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:47180 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbaGNJPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 05:15:40 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so1642811wgh.34
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 02:15:39 -0700 (PDT)
In-Reply-To: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-14 at 14:05 +0800, Xie Jianhua wrote:
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
> Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
> ---
>  drivers/net/bonding/bond_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3a451b6..4a72c2f 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3002,7 +3002,7 @@ static inline u32 bond_eth_hash(struct sk_buff *skb)
>  	struct ethhdr *data = (struct ethhdr *)skb->data;
>  
>  	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
> -		return data->h_dest[5] ^ data->h_source[5];
> +		return data->h_dest[5] ^ data->h_source[5] ^ data->h_proto;
>  
>  	return 0;
>  }

If you really want this, you also need to change the test, because
otherwise there is no guarantee data->h_proto is valid at his point.

if (skb_headlen(skb) >= sizeof(*data))
   ...
