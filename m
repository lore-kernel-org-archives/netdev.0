From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fib_trie: handle empty tree
Date: Mon, 11 Feb 2008 21:14:07 -0800 (PST)
Message-ID: <20080211.211407.08993863.davem@davemloft.net>
References: <20080211171250.60ad7bc5@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750814AbYBLFNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:13:36 -0500
In-Reply-To: <20080211171250.60ad7bc5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 11 Feb 2008 17:12:50 -0800

> To: David S. Miller <davem@davemloft.net>

When a user's name has "special" characters such as a "."  as mine
does, it must be surrounded by double-quotes or else it is a syntax
error by SMTP rules.  For this reason your patch postings were
rejected by vger.kernel.org

> This fixes possible problems when trie_firstleaf() returns NULL
> to trie_leafindex().
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index f5fba3f..2d89527 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1762,11 +1762,9 @@ static struct leaf *trie_leafindex(struct trie *t, int index)
>  {
>  	struct leaf *l = trie_firstleaf(t);
>  
> -	while (index-- > 0) {
> +	while (l && index-- > 0)
>  		l = trie_nextleaf(l);
> -		if (!l)
> -			break;
> -	}
> +
>  	return l;
>  }
>  
> -- 
> 1.5.3.8
> 
