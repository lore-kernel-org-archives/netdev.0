From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH net] liquidio: silence a locking static checker warning
Date: Fri, 28 Apr 2017 10:42:51 -0700
Message-ID: <20170428174251.GA1021@felix-thinkpad.cavium.com>
References: <20170428125715.h6d5ttnfq7rdnpni@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170428125715.h6d5ttnfq7rdnpni@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Apr 2017 15:57:15 +0300

> Presumably we never hit this return, but static checkers complain that
> we need to unlock so we may as well fix that.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
> index 201b9875f9bb..5cca73b8880b 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
> @@ -313,6 +313,7 @@ int octeon_mbox_process_message(struct octeon_mbox *mbox)
>  		return 0;
>  	}
>  
> +	spin_unlock_irqrestore(&mbox->lock, flags);
>  	WARN_ON(1);
>  
>  	return 0;

Thanks.

Acked-by: Felix Manlunas <felix.manlunas@cavium.com>
