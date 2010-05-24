From: Thomas Chou <thomas@wytron.com.tw>
Subject: Re: null dereference in ethoc_probe()
Date: Mon, 24 May 2010 08:29:30 +0800
Message-ID: <4BF9C86A.4080400@wytron.com.tw>
References: <20100522155455.GE22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr38.hinet.net ([168.95.4.138]:33959 "EHLO msr38.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab0EXAlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 May 2010 20:41:19 -0400
In-Reply-To: <20100522155455.GE22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> The patch 0baa080c75c: "ethoc: use system memory as buffer" introduced a
> potential null dereference.
> 
>   1060  free:
>   1061          if (priv->dma_alloc)
>                     ^^^^^^^^^^^^^^^
> 	priv can be null here.
> 
>   1062                  dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
>   1063                          netdev->mem_start);
>   1064          free_netdev(netdev);
> 
> Also I think the error handling is not as complete as it should be.  It
> seems like we should call devm_iounmap() and release some of the other
> resources as well.
> 
> regards,
> dan carpenter
> 
> 
> 
Hi Dan,

Thank you for reporting this bug. I will submit patch to fix this mistake.

Best regards,
Thomas
