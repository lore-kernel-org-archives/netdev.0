From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v5 6/7] vxlan: Add tx-vlan offload support.
Date: Thu, 01 Aug 2013 17:11:47 +0400
Message-ID: <51FA5E93.3070308@cogentembedded.com>
References: <1375312487-18789-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:62542 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab3HANLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 09:11:42 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so1415252lab.12
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 06:11:41 -0700 (PDT)
In-Reply-To: <1375312487-18789-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-08-2013 3:14, Pravin B Shelar wrote:

> Following patch allows transmit side vlan offload for vxlan
> devices.

> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v2-v3:
>   - Set NETIF_F_HW_VLAN_STAG_TX feature.
>   - Added WARN on vlan tag push.
>   - Fixed hw_features.
> ---
>   drivers/net/vxlan.c |   18 +++++++++++++++++-
>   1 files changed, 17 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index f9c7c75..2f35a2b 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
[...]
> @@ -1123,13 +1124,25 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
[...]
> +	if (vlan_tx_tag_present(skb)) {
> +		if (unlikely(!__vlan_put_tag(skb,
> +					     skb->vlan_proto,
> +					     vlan_tx_tag_get(skb)))) {
> +			WARN_ON(1);
> +			return -ENOMEM;
> +		}

		if (WARN_ON(!__vlan_put_tag(skb,
					    skb->vlan_proto,
					    vlan_tx_tag_get(skb))))
			return -ENOMEM;

should be equivalent.

WBR, Sergei
