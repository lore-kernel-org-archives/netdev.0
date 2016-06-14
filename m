From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ipvs: Lock socket before setting SK_CAN_REUSE
Date: Mon, 13 Jun 2016 20:12:04 -0700
Message-ID: <1465873924.7945.180.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
	 <1465868613-26146-5-git-send-email-quentin@armitage.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
To: Quentin Armitage <quentin@armitage.org.uk>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1465868613-26146-5-git-send-email-quentin@armitage.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-14 at 02:43 +0100, Quentin Armitage wrote:
> When other settings are changed in the socket it is locked, so
> lock the socket before setting SK_CAN_REUSE.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 29d73d8..dfac9ef 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1540,7 +1540,9 @@ static struct socket *make_receive_sock(struct netns_ipvs *ipvs, int id, int ifi
>  	}
>  
>  	/* it is equivalent to the REUSEADDR option in user-space */
> +	lock_sock(sock->sk);
>  	sock->sk->sk_reuse = SK_CAN_REUSE;
> +	release_sock(sock->sk);
>  	result = sysctl_sync_sock_size(ipvs);
>  	if (result > 0)
>  		set_sock_size(sock->sk, 0, result);


Have you tested this patch ?



