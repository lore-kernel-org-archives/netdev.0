From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/4] be2net: Add a few inline functions to test
 TXQ conditions
Date: Sun, 15 Feb 2015 15:37:49 +0300
Message-ID: <54E0931D.4090008@cogentembedded.com>
References: <1423986327-10069-1-git-send-email-sriharsha.basavapatna@emulex.com> <1423986327-10069-5-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:42501 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbbBOMhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 07:37:52 -0500
Received: by labgf13 with SMTP id gf13so23849009lab.9
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 04:37:50 -0800 (PST)
In-Reply-To: <1423986327-10069-5-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/15/2015 10:45 AM, Sriharsha Basavapatna wrote:

> - Check qfull condition
> - Check qwake condition
> - Check pkts pending completion

> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_main.c | 23 +++++++++++++++++++----
>   1 file changed, 19 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index b37b099..028b093 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -728,6 +728,22 @@ static u16 skb_ip_proto(struct sk_buff *skb)
>   		ip_hdr(skb)->protocol : ipv6_hdr(skb)->nexthdr;
>   }
>
> +static inline bool be_is_txq_full(struct be_tx_obj *txo)
> +{
> +	return ((atomic_read(&txo->q.used) + BE_MAX_TX_FRAG_COUNT) >=
> +		 txo->q.len);
> +}
> +
> +static inline bool be_can_txq_wake(struct be_tx_obj *txo)
> +{
> +	return (atomic_read(&txo->q.used) < txo->q.len / 2);
> +}
> +
> +static inline bool be_is_tx_compl_pending(struct be_tx_obj *txo)
> +{
> +	return (atomic_read(&txo->q.used) > txo->pend_wrb_cnt);
> +}
> +

    Parens not needed around the *return* expressions.

[...]

WBR, Sergei
