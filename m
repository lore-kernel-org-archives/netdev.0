From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] hostap_{pci,plx}.c: fix memory leaks
Date: Tue, 14 Mar 2006 13:25:29 +1100
Message-ID: <E1FIzE1-0003Ur-00@gondolin.me.apana.org.au>
References: <20060313222841.GQ13973@stusta.de>
Cc: jkmaline@cc.hut.fi, hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752101AbWCNC0S@vger.kernel.org>
To: bunk@stusta.de (Adrian Bunk)
In-Reply-To: <20060313222841.GQ13973@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:
> 
> +       if (pci_enable_device(pdev))
> +               return -EIO;
> +
>        hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
>        if (hw_priv == NULL)
>                return -ENOMEM;
>        memset(hw_priv, 0, sizeof(*hw_priv));
> 
> -       if (pci_enable_device(pdev))
> -               return -EIO;
> -

You've just turned it into a leak of a different kind.

Why not jump to the error exit instead?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
