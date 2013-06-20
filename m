From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 7/8] vxlan: Add tx-vlan offload support.
Date: Thu, 20 Jun 2013 16:29:54 +0400
Message-ID: <51C2F5C2.5050502@cogentembedded.com>
References: <1371713217-8310-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:58587 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab3FTM3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 08:29:54 -0400
Received: by mail-lb0-f181.google.com with SMTP id w10so5676023lbi.40
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 05:29:52 -0700 (PDT)
In-Reply-To: <1371713217-8310-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-06-2013 11:26, Pravin B Shelar wrote:

> Following patch allows transmit side vlan offload for vxlan
> devices.

> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>   drivers/net/vxlan.c |   15 ++++++++++++++-
>   1 files changed, 14 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e53c947..a7feba4 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
[...]
> @@ -1049,13 +1050,23 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
[...]
> +	if (vlan_tx_tag_present(skb)) {
> +		if (unlikely(!__vlan_put_tag(skb,
> +					     skb->vlan_proto,
> +					     vlan_tx_tag_get(skb)))) {
> +			return -ENOMEM;
> +		}

    You haven't run this patch thru scripts/checkpatch.pl, have you? It 
should have warned you about using {} on single statement branch.

> +		skb->vlan_tci = 0;
> +	}
> +

WBR, Sergei
