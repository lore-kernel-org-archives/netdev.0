From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: remove redundant NULL check.
Date: Tue, 12 Feb 2013 17:06:50 -0500 (EST)
Message-ID: <20130212.170650.89534546100043269.davem@davemloft.net>
References: <1360706086-31506-1-git-send-email-tipecaml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	mugunthanvnm@ti.com, zonque@gmail.com, hotforest@gmail.com,
	Julia.Lawall@lip6.fr, netdev@vger.kernel.org
To: tipecaml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360706086-31506-1-git-send-email-tipecaml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyril Roelandt <tipecaml@gmail.com>
Date: Tue, 12 Feb 2013 22:54:46 +0100

> cpdma_chan_destroy() on a NULL pointer is a no-op, so the NULL check in
> cpdma_ctlr_destroy() can safely be removed.
> 
> Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
 ...
> @@ -450,8 +450,7 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
>  		cpdma_ctlr_stop(ctlr);
>  
>  	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
> -		if (ctlr->channels[i])
> -			cpdma_chan_destroy(ctlr->channels[i]);
> +		cpdma_chan_destroy(ctlr->channels[i]);
>  	}

SInce this is now a single statement basic block, remove the
surrounding braces.
