From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: [KJ] replacing kmalloc with kzalloc in drivers/net/sb1250-mac.c
Date: Mon, 13 Aug 2007 11:24:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0708131123020.2277@localhost.localdomain>
References: <1186999123.29518.18.camel@bluegenie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Surya Prabhakar N <surya.prabhakar@wipro.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S947256AbXHMQyk@vger.kernel.org>
In-Reply-To: <1186999123.29518.18.camel@bluegenie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Aug 2007, Surya Prabhakar N wrote:

> Hi,
>    Replacing kmalloc with kzalloc and cleaning up memset in
> drivers/net/sb1250-mac.c
>
>
> Signed-off-by: Surya Prabhakar <surya.prabhakar@wipro.com>
> ---
>
> diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
> index e7fdcf1..2dca5a7 100644
> --- a/drivers/net/sb1250-mac.c
> +++ b/drivers/net/sb1250-mac.c
> @@ -760,7 +760,7 @@ static void sbdma_initctx(sbmacdma_t *d,
>
>  	d->sbdma_dscrtable_unaligned =
>  	d->sbdma_dscrtable = (sbdmadscr_t *)
                             ^^^^^^^^^^^^^^^
> -		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
> +		kzalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);

i'm fairly sure you can drop all of those superfluous casts when
calling one of those memory allocation routines.

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
