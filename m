From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix socket code abuses csum_partial
Date: Thu, 06 Mar 2014 16:19:20 -0500 (EST)
Message-ID: <20140306.161920.445388572324462521.davem@davemloft.net>
References: <20140304210104.42ef3dd8@kryten>
	<20140305142958.1ed421dc@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, gustavold@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbaCFVTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 16:19:22 -0500
In-Reply-To: <20140305142958.1ed421dc@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Wed, 5 Mar 2014 14:29:58 +1100

> Index: b/net/unix/af_unix.c
> ===================================================================
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -163,9 +163,8 @@ static inline void unix_set_secdata(stru
>  
>  static inline unsigned int unix_hash_fold(__wsum n)
>  {
> -	unsigned int hash = (__force unsigned int)n;
> +	unsigned int hash = (__force unsigned int)csum_fold(n);
>  
> -	hash ^= hash>>16;
>  	hash ^= hash>>8;
>  	return hash&(UNIX_HASH_SIZE-1);

Looks great, I'll apply this, thanks Anton!
