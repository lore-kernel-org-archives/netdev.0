From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: free tx buffers when completions
 never arrive
Date: Thu, 18 Feb 2010 02:16:16 -0800 (PST)
Message-ID: <20100218.021616.127015823.davem@davemloft.net>
References: <20100218093603.GA28912@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754997Ab0BRKQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 05:16:04 -0500
In-Reply-To: <20100218093603.GA28912@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 18 Feb 2010 15:06:03 +0530

> In cases like when a pci device is disconnected after a pci error,
> pending tx completions will never arrive. Unmap and free such
> buffers in the tx cleanup path.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>
> ---
>  drivers/net/benet/be_main.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index 68e7848..810d2a4 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -1128,6 +1128,9 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
>  	struct be_queue_info *txq = &adapter->tx_obj.q;
>  	struct be_eth_tx_compl *txcp;
>  	u16 end_idx, cmpl = 0, timeo = 0;
> +	struct sk_buff **sent_skbs = adapter->tx_obj.sent_skb_list;
> +	struct sk_buff *sent_skb;
> +        bool dummy_wrb;

Some of your lines start with tabs, some with spaces.   You
have to use tabs consistently.

> +	
> +	/* free posted tx for which compls will never arrive */
> +        while (atomic_read(&txq->used)) {
> +                sent_skb = sent_skbs[txq->tail];
> +                end_idx = txq->tail;
> +                index_adv(&end_idx,
> +                        wrb_cnt_for_skb(sent_skb, &dummy_wrb) - 1, txq->len);
> +                be_tx_compl_process(adapter, end_idx);
> +        }
>  }

More tabbing and indentation problems here too.
