From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH -rt] Fix initialization of spinlock in irttp_dup()
Date: Tue, 20 Mar 2007 23:50:12 +0200
Message-ID: <20070320215012.GA4089@sortiz.org>
References: <20070320192233.GA14543@plexity.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Ingo Molnar <mingo@elte.hu>, Daniel Walker <dwalker@mvista.com>
To: Deepak Saxena <dsaxena@plexity.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:56718 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913AbXCTVuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 17:50:20 -0400
Content-Disposition: inline
In-Reply-To: <20070320192233.GA14543@plexity.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Deepak,

On Tue, Mar 20, 2007 at 12:22:33PM -0700, Deepak Saxena wrote:
> This was found around the 2.6.10 timeframe when testing with the -rt patch
> and I believe is still is an issue. irttp_dup() does a memcpy() of the tsap_cb 
> structure causing the spinlock protecting various fields in the structure to be 
> duped.  This works OK in the non-RT case but in the RT case we end up with two 
> mutexes pointing to the same wait_list and leading to an OOPS. Fix is to simply
> initialize the spinlock after the memcpy().
This has just made it to the netdev and stable trees.
See:
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=7bb1bbe615de25d955b974cb47d40fa198154bb9

Cheers,
Samuel.


> Signed-off-by: Deepak Saxena <dsaxena@mvista.com>
> 
> diff --git a/net/irda/irttp.c b/net/irda/irttp.c
> index a7486b3..df2b2f7 100644
> --- a/net/irda/irttp.c
> +++ b/net/irda/irttp.c
> @@ -1441,6 +1441,7 @@ struct tsap_cb *irttp_dup(struct tsap_cb
>  	}
>  	/* Dup */
>  	memcpy(new, orig, sizeof(struct tsap_cb));
> +	spin_lock_init(&new->lock);
>  
>  	/* We don't need the old instance any more */
>  	spin_unlock_irqrestore(&irttp->tsaps->hb_spinlock, flags);
> 
> 
> -- 
> Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net
> 
> In the end, they will not say, "those were dark times,"  they will ask
> "why were their poets silent?" - Bertolt Brecht

