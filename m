From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH 2/5] arcnet: com90xx: add __init attribute
Date: Tue, 19 Apr 2016 08:56:57 +0200
Message-ID: <20160419065657.GD2471@pengutronix.de>
References: <1460991338-9845-1-git-send-email-Julia.Lawall@lip6.fr>
 <1460991338-9845-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Luis R . Rodriguez" <mcgrof@kernel.org>,
	Josh Triplett <josh@joshtriplett.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59737 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbcDSG5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 02:57:04 -0400
Content-Disposition: inline
In-Reply-To: <1460991338-9845-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 04:55:35PM +0200, Julia Lawall wrote:
> Add __init attribute on a function that is only called from other __init
> functions and that is not inlined, at least with gcc version 4.8.4 on an
> x86 machine with allyesconfig.  Currently, the function is put in the
> .text.unlikely segment.  Declaring it as __init will cause it to be put in
> the .init.text and to disappear after initialization.
> 
> The result of objdump -x on the function before the change is as follows:
> 
> 0000000000000000 l     F .text.unlikely 00000000000000bf check_mirror
> 
> And after the change it is as follows:
> 
> 0000000000000000 l     F .init.text	00000000000000ba check_mirror
> 
> Done with the help of Coccinelle.  The semantic patch checks for local
> static non-init functions that are called from an __init function and are
> not called from any other function.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 

Acked-by: Michael Grzeschik <mgr@pengutronix.de>

> ---
>  drivers/net/arcnet/com90xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
> index 0d9b45f..81f90c4 100644
> --- a/drivers/net/arcnet/com90xx.c
> +++ b/drivers/net/arcnet/com90xx.c
> @@ -433,7 +433,7 @@ static void __init com90xx_probe(void)
>  	kfree(iomem);
>  }
>  
> -static int check_mirror(unsigned long addr, size_t size)
> +static int __init check_mirror(unsigned long addr, size_t size)
>  {
>  	void __iomem *p;
>  	int res = -1;
> 
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
