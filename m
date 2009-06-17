From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] skbuff: skb_mac_header_was_set is always true on >32 bit
Date: Wed, 17 Jun 2009 13:37:16 -0300
Message-ID: <20090617163716.GA21530@ghostprotocols.net>
References: <20090617082327.196eda07@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57257 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756908AbZFQQhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 12:37:31 -0400
Content-Disposition: inline
In-Reply-To: <20090617082327.196eda07@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Jun 17, 2009 at 08:23:27AM -0700, Stephen Hemminger escreveu:
> Looking at the crash in log_martians(), one suspect is that the check for
> mac header being set is not correct.  The value of mac_header defaults to
> 0 on allocation, therefore skb_mac_header_was_set will always be true on
> platforms using NET_SKBUFF_USES_OFFSET.
> 
> Arnaldo, is this correct?
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Yeah, looks right, I forgot to initialize it to the value I changed the
test in skb_mac_header_was_set when doing the offset patch :-\

Thanks!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> --- a/net/core/skbuff.c	2009-06-17 08:16:46.235188728 -0700
> +++ b/net/core/skbuff.c	2009-06-17 08:17:25.810314332 -0700
> @@ -201,6 +201,10 @@ struct sk_buff *__alloc_skb(unsigned int
>  	skb->data = data;
>  	skb_reset_tail_pointer(skb);
>  	skb->end = skb->tail + size;
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +	skb->mac_header = ~0U;
> +#endif
> +
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
>  	atomic_set(&shinfo->dataref, 1);
