From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/6] drivers/net/fs_enet: remove null pointer dereference
Date: Thu, 22 May 2008 06:27:10 -0400
Message-ID: <48354A7E.5070105@garzik.org>
References: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60820 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764628AbYEVK1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:27:19 -0400
In-Reply-To: <Pine.LNX.4.64.0805121537590.3694@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> The following code appears in the function fs_init_instance in the file drivers/net/fs_enet/fs_enet-main.c.
> 
> 	if (fep->ops == NULL) {
> 		printk(KERN_ERR DRV_MODULE_NAME
> 		       ": %s No matching ops found (%d).\n",
> 		       ndev->name, fpi->fs_no);
> 		err = -EINVAL;
> 		goto err;
> 	}
> 
> This code implies that at the point of err, fep->ops can be NULL, so an
> extra test is needed before dereferencing this value.
> 
> 
> This problem was found using the following semantic match
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression E, E1;
> identifier f;
> statement S1,S2,S3;
> @@
> 
> * if (E == NULL)
> {
>   ... when != if (E == NULL) S1 else S2
>       when != E = E1
> * E->f
>   ... when any
>   return ...;
> }
> else S3
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

applied

