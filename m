From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] [Net] Support Xen accelerated network plugin
 modules
Date: Mon, 21 May 2007 10:50:03 -0700
Message-ID: <20070521105003.7fceb584@freepuppy>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com, herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:56793 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756770AbXEURvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 13:51:44 -0400
In-Reply-To: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 May 2007 14:16:48 +0100
Kieran Mansley <kmansley@solarflare.com> wrote:

> Add support to Xen netfront for accelerated plugin module
> 
> diff -r ce3d5c548e67 linux-2.6-xen-
> sparse/drivers/xen/netfront/netfront.c
> --- a/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c Thu May 17
> 09:56:38 2007 +0100
> +++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c Fri May 18
> 10:26:34 2007 +0100
>
> +/*
> + * Initialise the netfront state of an accelerator plugin module.
> + */ 
> +static int init_accelerator(const char *frontend, 
> +                            struct netfront_accelerator **result)
> +{
> +        struct netfront_accelerator *accelerator = 
> +                kmalloc(sizeof(struct netfront_accelerator),
> GFP_KERNEL);


> +
> +                        if ( accelerator->hooks == NULL )
> +                                DPRINTK("%s: no hooks set",
> __FUNCTION__);
> +                        else {
> +                                spin_unlock_irqrestore
> (&accelerators_lock, flags);
> +                                accelerator->hooks->new_device(np-
> >netdev, dev);
> +                                spin_lock_irqsave(&accelerators_lock,
> flags);
> +                        }
> +
> +                        if ( (--accelerator->hooks_usecount) == 0 )
> +                                accelerator_remove_hooks(accelerator);
> +                        spin_unlock_irqrestore(&accelerators_lock,
> flags);

Your mailer is word wrapping the patch so it won't apply as is.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
