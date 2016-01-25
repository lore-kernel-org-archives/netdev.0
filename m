From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 3/3] defxx: fix build warning
Date: Mon, 25 Jan 2016 07:07:54 +0000 (GMT)
Message-ID: <alpine.LFD.2.20.1601250654160.7055@eddie.linux-mips.org>
References: <1453702507-736-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: (from localhost user: 'macro', uid#1010) by eddie.linux-mips.org
        with ESMTP id S27008314AbcAYHHyMugVd (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Mon, 25 Jan 2016 08:07:54 +0100
In-Reply-To: <1453702507-736-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jan 2016, Sudip Mukherjee wrote:

> We are getting many build warning about:
> 'bar_start' may be used uninitialized
> and
> 'bar_len' may be used uninitialized
> 
> They are not actually uninitialized as dfx_get_bars() will initialize
> them properly. But still lets have them initialized just to satisfy the
> compiler.

 Which compiler/version is that?

> diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
> index 7f975a2..4113535 100644
> --- a/drivers/net/fddi/defxx.c
> +++ b/drivers/net/fddi/defxx.c
> @@ -533,8 +533,8 @@ static int dfx_register(struct device *bdev)
>  	const char *print_name = dev_name(bdev);
>  	struct net_device *dev;
>  	DFX_board_t	  *bp;			/* board pointer */
> -	resource_size_t bar_start[3];		/* pointers to ports */
> -	resource_size_t bar_len[3];		/* resource length */
> +	resource_size_t bar_start[3] = {0, 0, 0};	/* pointers to ports */
> +	resource_size_t bar_len[3] = {0, 0, 0};		/* resource length */
>  	int alloc_size;				/* total buffer size used */
>  	struct resource *region;
>  	int err = 0;

 Just setting the first element will do, the rest will then be implicitly 
zeroed, following the semantics of initialisers in C.  So just do:

	resource_size_t bar_start[3] = {0};	/* pointers to ports */
	resource_size_t bar_len[3] = {0};	/* resource length */

for brevity and to save formatting.

> @@ -3697,8 +3697,8 @@ static void dfx_unregister(struct device *bdev)
>  	int dfx_bus_pci = dev_is_pci(bdev);
>  	int dfx_bus_tc = DFX_BUS_TC(bdev);
>  	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
> -	resource_size_t bar_start[3];		/* pointers to ports */
> -	resource_size_t bar_len[3];		/* resource lengths */
> +	resource_size_t bar_start[3] = {0, 0, 0};	/* pointers to ports */
> +	resource_size_t bar_len[3] = {0, 0, 0};		/* resource lengths */
>  	int		alloc_size;		/* total buffer size used */
>  
>  	unregister_netdev(dev);

 Likewise here.  Please resend with the update requested and I'll ack it.

 Thanks for your submission!

  Maciej
