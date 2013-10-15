From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] be2net: drop non-tso frames longer than mtu
Date: Tue, 15 Oct 2013 17:45:21 +0400
Message-ID: <525D46F1.6060502@cogentembedded.com>
References: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com> <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:47934 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932270Ab3JONqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 09:46:25 -0400
Received: by mail-lb0-f172.google.com with SMTP id x18so6889517lbi.31
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 06:46:24 -0700 (PDT)
In-Reply-To: <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 15-10-2013 15:56, Sathya Perla wrote:

> From: Vasundhara Volam <vasundhara.volam@emulex.com>

> Pktgen can generate non-TSO frames of arbitrary length disregarding
> the MTU value of the physical interface. Drop such frames in the driver
> instead of sending them to HW as it cannot handle such frames.

> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++--
>   1 files changed, 7 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..76057b8 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -855,6 +855,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
>   	unsigned int eth_hdr_len;
>   	struct iphdr *ip;
>
> +	/* Don't allow non-TSO packets longer than MTU */
> +	eth_hdr_len = (ntohs(skb->protocol) == ETH_P_8021Q) ?
> +			VLAN_ETH_HLEN : ETH_HLEN;
> +	if (!skb_is_gso(skb) &&
> +	    (skb->len - eth_hdr_len) > adapter->netdev->mtu)
> +			goto tx_drop;

    This *goto* is indented one tab too much.

WBR, Sergei
