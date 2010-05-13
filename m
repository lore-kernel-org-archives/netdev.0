From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH 14/20] drivers/net/vmxnet3: Use kzalloc
Date: Thu, 13 May 2010 14:20:43 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D703353E61EE@EXCH-MBX-3.vmware.com>
References: <Pine.LNX.4.64.1005132204040.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: Julia Lawall <julia@diku.dk>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:45992 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753389Ab0EMVUq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 17:20:46 -0400
In-Reply-To: <Pine.LNX.4.64.1005132204040.6282@ask.diku.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good. Thanks for doing this!

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

- Bhavesh
 
Bhavesh P. Davda

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Julia Lawall
> Sent: Thursday, May 13, 2010 1:06 PM
> To: Shreyas Bhatewara; VMware, Inc.; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; kernel-janitors@vger.kernel.org
> Subject: [Pv-drivers] [PATCH 14/20] drivers/net/vmxnet3: Use kzalloc
> 
> From: Julia Lawall <julia@diku.dk>
> 
> Use kzalloc rather than the combination of kmalloc and memset.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression x,size,flags;
> statement S;
> @@
> 
> -x = kmalloc(size,flags);
> +x = kzalloc(size,flags);
>  if (x == NULL) S
> -memset(x, 0, size);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff -u -p a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1369,13 +1369,12 @@ vmxnet3_rq_create(struct vmxnet3_rx_queu
> 
>  	sz = sizeof(struct vmxnet3_rx_buf_info) * (rq->rx_ring[0].size +
>  						   rq->rx_ring[1].size);
> -	bi = kmalloc(sz, GFP_KERNEL);
> +	bi = kzalloc(sz, GFP_KERNEL);
>  	if (!bi) {
>  		printk(KERN_ERR "%s: failed to allocate rx bufinfo\n",
>  		       adapter->netdev->name);
>  		goto err;
>  	}
> -	memset(bi, 0, sz);
>  	rq->buf_info[0] = bi;
>  	rq->buf_info[1] = bi + rq->rx_ring[0].size;
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
