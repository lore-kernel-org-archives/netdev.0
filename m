From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3: Wait longer for control packets on initialization
Date: Mon, 26 Apr 2010 19:16:28 -0700
Message-ID: <4BD648FC.80602@chelsio.com>
References: <201004261238.27919.adetsch@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andre Detsch <adetsch@br.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32938 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab0D0CQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 22:16:04 -0400
In-Reply-To: <201004261238.27919.adetsch@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andre Detsch wrote:
> In some Power7 platforms, when using VIOS (Virtual I/O Server), we
> need to wait longer for control packets to finish transfer during
> initialization.
> Without this change, initialization may fail prematurely.
>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
> Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
>   

Acked-by: Divy Le Ray <divy@chelsio.com>

> Index: linux-2.6.34-rc5/drivers/net/cxgb3/cxgb3_main.c
> ===================================================================
> --- linux-2.6.34-rc5.orig/drivers/net/cxgb3/cxgb3_main.c	2010-04-23 18:59:43.000000000 -0300
> +++ linux-2.6.34-rc5/drivers/net/cxgb3/cxgb3_main.c	2010-04-23 18:59:55.000000000 -0300
> @@ -439,7 +439,7 @@ static void free_irq_resources(struct ad
>  static int await_mgmt_replies(struct adapter *adap, unsigned long init_cnt,
>  			      unsigned long n)
>  {
> -	int attempts = 5;
> +	int attempts = 10;
>
>  	while (adap->sge.qs[0].rspq.offload_pkts < init_cnt + n) {
>  		if (!--attempts)
>   

