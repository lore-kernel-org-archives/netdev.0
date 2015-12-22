From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: fix use-after-free after cloning struct dccp_sock
Date: Tue, 22 Dec 2015 15:34:25 -0500 (EST)
Message-ID: <20151222.153425.727988801786072877.davem@davemloft.net>
References: <1450644807-852-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@kernel.org, edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450644807-852-1-git-send-email-vegard.nossum@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Sun, 20 Dec 2015 21:53:27 +0100

> @@ -115,6 +115,10 @@ struct sock *dccp_create_openreq_child(const struct sock *sk,
>  		newdp->dccps_isr = dreq->dreq_isr;
>  		newdp->dccps_gsr = dreq->dreq_gsr;
>  
> +		newdp->dccps_hc_rx_ackvec = NULL;
> +		newdp->dccps_hc_rx_ccid = NULL;
> +		newdp->dccps_hc_tx_ccid = NULL;

->dccps_hc_rx_ackvec is set to NULL several lines above this, so you don't
need to add that case here.

WRT the ccid pointers, I don't think we can just NULL them out.

If the parent socket has these CCID features enabled, we have to
clone them into the child somehow.
