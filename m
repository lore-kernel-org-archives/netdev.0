From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/11] DMA sync errors
Date: Wed, 20 Jan 2010 16:34:10 -0800
Message-ID: <20100120163410.774f0c4c@nehalam>
References: <20100120204459.820265084@vyatta.com>
	<20100120.144639.31770545.davem@davemloft.net>
	<20100120152832.06a905a5@nehalam>
	<20100120.161805.118613816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35209 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240Ab0AUAe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 19:34:27 -0500
In-Reply-To: <20100120.161805.118613816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 16:18:05 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 20 Jan 2010 15:28:32 -0800
> 
> > This should fix the dma-debug API code (and documentation), to
> > avoid false positives when sync is done on a partial map.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>  ...
> > --- a/lib/dma-debug.c	2010-01-20 15:22:55.919519883 -0800
> > +++ b/lib/dma-debug.c	2010-01-20 15:26:31.648895638 -0800
> > @@ -285,11 +285,9 @@ static struct dma_debug_entry *hash_buck
> >  	}
> >  
> >  	/*
> > -	 * If we have multiple matches but no perfect-fit, just return
> > -	 * NULL.
> > +	 * If we have multiple matches but no perfect-fit
> > +	 * return best value and let caller deal with it.
> >  	 */
> > -	ret = (matches == 1) ? ret : NULL;
> > -
> >  	return ret;
> >  }
> >  
> 
> I think you have to enforce a perfect-fit match for the
> non-SYNC cases.
> 
> check_sync() can pass in 'true' for a new bool argument "partial_ok"
> added to hash_bucket_find() whereas check_unmap() can pass 'false'.
> 
> get_nr_mapped_entries() should pass 'false' as well.

check_unmap has checks for different size, different type,
call_ents, direction etc.

The code for get_nr_mapped_entries() is the only question;
it is used by unmap_sg() and probably needs perfect match only.



