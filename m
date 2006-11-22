From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] net: fix kfifo_alloc() error check
Date: Wed, 22 Nov 2006 11:02:46 -0800
Message-ID: <20061122110246.791beabd@freekitty>
References: <20061122183335.GA2985@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:9874 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1756590AbWKVTCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 14:02:51 -0500
To: Akinobu Mita <akinobu.mita@gmail.com>
In-Reply-To: <20061122183335.GA2985@APFDCB5C>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Nov 2006 03:33:35 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> The return value of kfifo_alloc() should be checked by IS_ERR().
> 
> Cc: Stephen Hemminger <shemminger@osdl.org>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> 
> ---
>  net/dccp/probe.c     |    2 ++
>  net/ipv4/tcp_probe.c |    2 ++
>  2 files changed, 4 insertions(+)
> 
> Index: work-fault-inject/net/ipv4/tcp_probe.c
> ===================================================================
> --- work-fault-inject.orig/net/ipv4/tcp_probe.c
> +++ work-fault-inject/net/ipv4/tcp_probe.c
> @@ -156,6 +156,8 @@ static __init int tcpprobe_init(void)
>  	init_waitqueue_head(&tcpw.wait);
>  	spin_lock_init(&tcpw.lock);
>  	tcpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &tcpw.lock);
> +	if (IS_ERR(tcpw.fifo))
> +		return PTR_ERR(tcpw.fifo);
>  
>  	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
>  		goto err0;
> Index: work-fault-inject/net/dccp/probe.c
> ===================================================================
> --- work-fault-inject.orig/net/dccp/probe.c
> +++ work-fault-inject/net/dccp/probe.c
> @@ -160,6 +160,8 @@ static __init int dccpprobe_init(void)
>  	init_waitqueue_head(&dccpw.wait);
>  	spin_lock_init(&dccpw.lock);
>  	dccpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &dccpw.lock);
> +	if (IS_ERR(dccpw.fifo))
> +		return PTR_ERR(dccpw.fifo);
>  
>  	if (!proc_net_fops_create(procname, S_IRUSR, &dccpprobe_fops))
>  		goto err0;

Good thanks

-- 
Stephen Hemminger <shemminger@osdl.org>
