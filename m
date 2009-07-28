From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] net: net_assign_generic()  fix
Date: Tue, 28 Jul 2009 17:03:01 +0400
Message-ID: <4A6EF705.6070403@openvz.org>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3186 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025AbZG1NDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 09:03:10 -0400
In-Reply-To: <4A6EF0BF.2050801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm...
> 
> Real bug may be fixed by followed patch ? (yet untested, sorry...)
> 
> [PATCH] net: net_assign_generic() fix 
> 
> memcpy() should take into account size of pointers,
> not only number of pointers to copy.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> ---
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index b7292a2..1972830 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -488,7 +488,7 @@ int net_assign_generic(struct net *net, int id, void *data)
>  	 */
>  
>  	ng->len = id;
> -	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len);
> +	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
>  
>  	rcu_assign_pointer(net->gen, ng);
>  	call_rcu(&old_ng->rcu, net_generic_release);
> 
> 

