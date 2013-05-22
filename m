From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 11:20:16 -0700
Message-ID: <1369246816.2143.84.camel@joe-AO722>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369244868.3301.343.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-22 at 10:47 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> nf_conntrack_lock is a monolithic lock and suffers from huge contention
> on current generation servers (8 or more core/threads).
[]
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
[]
> @@ -76,7 +76,8 @@ struct nf_conn {
>             plus 1 for any connection(s) we are `master' for */
>  	struct nf_conntrack ct_general;
>  
> -	spinlock_t lock;
> +	spinlock_t	lock;
> +	u16		cpu;

trivia:

What's the real value in not using int here?


