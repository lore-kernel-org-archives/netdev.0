From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [patch -next] vmxnet3: locking problems in xmit
Date: Mon, 20 Dec 2010 09:09:13 -0800
Message-ID: <382C2929804A6B469FF4A4200E716F480431304B17CC@EXCH-MBX-1.vmware.com>
References: <20101220130315.GY1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:12475 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932875Ab0LTRJR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 12:09:17 -0500
In-Reply-To: <20101220130315.GY1936@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indeed, indeed. Thanks for catching that and fixing it!

> 
> There were several paths that didn't release their locks.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 23154cf..939e546 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -980,7 +980,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
> vmxnet3_tx_queue *tq,
>  		}
>  	} else {
>  		tq->stats.drop_hdr_inspect_err++;
> -		goto drop_pkt;
> +		goto unlock_drop_pkt;
>  	}
> 
>  	/* fill tx descs related to addr & len */
> @@ -1052,6 +1052,8 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct
> vmxnet3_tx_queue *tq,
> 
>  hdr_too_big:
>  	tq->stats.drop_oversized_hdr++;
> +unlock_drop_pkt:
> +	spin_unlock_irqrestore(&tq->tx_lock, flags);
>  drop_pkt:
>  	tq->stats.drop_total++;
>  	dev_kfree_skb(skb);
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
