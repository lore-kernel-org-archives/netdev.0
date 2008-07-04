From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v3] ibm_newemac: Fixes kernel crashes when speed of cable
 connected changes
Date: Fri, 04 Jul 2008 08:17:30 -0400
Message-ID: <486E14DA.6070104@garzik.org>
References: <1214902685-10489-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbYGDMRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:17:36 -0400
In-Reply-To: <1214902685-10489-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> The descriptor pointers were not initialized to NIL values, so it was
> poiniting to some random addresses which was completely invalid. This
> fix takes care of initializing the descriptor to NIL values and clearing
> the valid descriptors on clean ring operation.
> 
> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index 5d2108c..ca63fa0 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -2719,6 +2719,8 @@ static int __devinit emac_probe(struct of_device *ofdev,
>  	/* Clean rings */
>  	memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));
>  	memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));
> +	memset(dev->tx_skb, 0, NUM_TX_BUFF * sizeof(struct sk_buff *));
> +	memset(dev->rx_skb, 0, NUM_RX_BUFF * sizeof(struct sk_buff *));
>  

applied to 2.6.26


