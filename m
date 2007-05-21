From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/4] [Net] Support Xen accelerated network plugin
 modules
Date: Mon, 21 May 2007 10:54:45 -0700
Message-ID: <20070521105445.60d69f2c@freepuppy>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com, herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:56945 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755838AbXEUR4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 13:56:13 -0400
In-Reply-To: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> +
> +/* 
> + * Macro to call one of the accelerator's function hooks.  The use
> + * count for the accelerator's hooks is incremented for the duration
> + * of the call to prevent the accelerator being able to modify the
> + * hooks in the middle (by, for example, unloading)
> + */ 
> +#define netfront_call_accelerator_hook(_np, _hook, _args...)
> \
> +        do {
> \
> +                if ( (_np)->accel_vif_state.hooks ) {
> \
> +                        unsigned flags;
> \
> +                        spin_lock_irqsave(&accelerators_lock, flags);
> \
> +                        ++(_np)->accelerator->hooks_usecount;
> \
> +                        spin_unlock_irqrestore(&accelerators_lock,
> flags); \
> +                        if ( (_np)->accel_vif_state.hooks )
> \
> +                                (_np)->accel_vif_state.hooks->_hook
> (_args); \
> +                        spin_lock_irqsave(&accelerators_lock, flags);
> \
> +                        if ( (--(_np)->accelerator->hooks_usecount) ==
> 0 ) \
> +                                accelerator_remove_hooks((_np)-
> >accelerator); \
> +                        spin_unlock_irqrestore(&accelerators_lock,
> flags); \
> +                }
> \
> +        } while(0)


Gag, why a macro... See earlier comments about suing RCU and eliminating
the refcount and locking overhead.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
