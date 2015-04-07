From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 12:54:18 -0700
Message-ID: <552435EA.6010609@redhat.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com> <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nix <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbbDGTyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:54:21 -0400
In-Reply-To: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2015 11:01 AM, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>   drivers/net/ethernet/via/via-rhine.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index a191afc..00fea3d 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
>   				break;
>   			}
>   			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
> +			wmb();
>   		}
>   		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
>   	}

Do you need a full wmb() here or would a dma_wmb() be enough?  It could 
make a difference on some processor architectures.

- Alex
