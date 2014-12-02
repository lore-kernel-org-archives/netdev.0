From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: Neaten and reduce size of compute_score
 functions
Date: Mon, 01 Dec 2014 18:59:01 -0800
Message-ID: <1417489141.4442.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417484341.4894.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417484341.4894.6.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-12-01 at 17:39 -0800, Joe Perches wrote:
> The compute_score functions are a bit difficult to read.
> 
> Neaten them a bit to reduce object sizes and make them a
> bit more intelligible.
> 
> Return early to avoid indentation and avoid unnecessary
> initializations.

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/ipv4/udp.c | 111 +++++++++++++++++++++++++++++++-------------------------
>  net/ipv6/udp.c | 113 ++++++++++++++++++++++++++++++++-------------------------
>  2 files changed, 125 insertions(+), 99 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index b2d6068..227e6ad 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -336,38 +336,45 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
>  	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
>  }
>  
> -static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
> -			 unsigned short hnum,
> -			 __be16 sport, __be32 daddr, __be16 dport, int dif)
> +static inline int compute_score(struct sock *sk, struct net *net,
> +				__be32 saddr, unsigned short hnum, __be16 sport,
> +				__be32 daddr, __be16 dport, int dif)
>  {
> -	int score = -1;
> +	int score;
> +	struct inet_sock *inet;
>  
> -	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
> -			!ipv6_only_sock(sk)) {
> -		struct inet_sock *inet = inet_sk(sk);
> +	if (!(net_eq(sock_net(sk), net) &&
> +	      udp_sk(sk)->udp_port_hash == hnum &&
> +	      !ipv6_only_sock(sk)))
> +		return -1

Or even better :


	if (!net_eq(sock_net(sk), net) ||
	    udp_sk(sk)->udp_port_hash != hnum ||
	    ipv6_only_sock(sk))
		return -1;
