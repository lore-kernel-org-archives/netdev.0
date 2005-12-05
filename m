From: Johannes Stezenbach <js@linuxtv.org>
Subject: Re: [PATCH linux-2.6.15-rc5] sk98lin: rx checksum offset not set
Date: Mon, 5 Dec 2005 20:22:39 +0100
Message-ID: <20051205192239.GA4150@linuxtv.org>
References: <Pine.LNX.4.64.0512032155290.3099@g5.osdl.org> <20051204234320.GA7478@linuxtv.org> <20051205110040.47adf428@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932527AbVLETW6@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20051205110040.47adf428@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005, Stephen Hemminger wrote:
> The checksum offsets for receive offload were not being set correctly.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I can confirm that this patch fixes the problem for me.

Thanks,
Johannes

> Index: linux-2.6/drivers/net/sk98lin/skge.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/sk98lin/skge.c
> +++ linux-2.6/drivers/net/sk98lin/skge.c
> @@ -818,7 +818,7 @@ uintptr_t VNextDescr;	/* the virtual bus
>  		/* set the pointers right */
>  		pDescr->VNextRxd = VNextDescr & 0xffffffffULL;
>  		pDescr->pNextRxd = pNextDescr;
> -		pDescr->TcpSumStarts = 0;
> +		if (!IsTx) pDescr->TcpSumStarts = ETH_HLEN << 16 | ETH_HLEN;
>  
>  		/* advance one step */
>  		pPrevDescr = pDescr;
> @@ -2169,7 +2169,7 @@ rx_start:	
>  		} /* frame > SK_COPY_TRESHOLD */
>  
>  #ifdef USE_SK_RX_CHECKSUM
> -		pMsg->csum = pRxd->TcpSums;
> +		pMsg->csum = pRxd->TcpSums & 0xffff;
>  		pMsg->ip_summed = CHECKSUM_HW;
>  #else
>  		pMsg->ip_summed = CHECKSUM_NONE;
> 
