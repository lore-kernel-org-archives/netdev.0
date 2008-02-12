From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH][NETLABEL]: Fix lookup logic of netlbl_domhsh_search_def.
Date: Tue, 12 Feb 2008 11:34:09 -0500
Message-ID: <200802121134.09965.paul.moore@hp.com>
References: <47B1C8E4.6010908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:2132 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757908AbYBLQeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 11:34:23 -0500
In-Reply-To: <47B1C8E4.6010908@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 February 2008 11:27:16 am Pavel Emelyanov wrote:
> Currently, if the call to netlbl_domhsh_search succeeds the
> return result will still be NULL.
>
> Fix that, by returning the found entry (if any).
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch, thanks.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>
> diff --git a/net/netlabel/netlabel_domainhash.c
> b/net/netlabel/netlabel_domainhash.c index 9a8ea01..fd46231 100644
> --- a/net/netlabel/netlabel_domainhash.c
> +++ b/net/netlabel/netlabel_domainhash.c
> @@ -150,11 +150,11 @@ static struct netlbl_dom_map
> *netlbl_domhsh_search_def(const char *domain) entry =
> netlbl_domhsh_search(domain);
>  	if (entry == NULL) {
>  		entry = rcu_dereference(netlbl_domhsh_def);
> -		if (entry != NULL && entry->valid)
> -			return entry;
> +		if (entry != NULL && !entry->valid)
> +			entry = NULL;
>  	}
>
> -	return NULL;
> +	return entry;
>  }
>
>  /*

-- 
paul moore
linux security @ hp
