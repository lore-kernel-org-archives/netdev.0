From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 05/10] Remove local address check on IP output
Date: Wed, 10 Jan 2007 07:47:07 +0100
Message-ID: <45A48BEB.2070207@trash.net>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
	<20070103163627.14635.88250.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <20070103163627.14635.88250.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

KOVACS Krisztian wrote:
> ip_route_output() contains a check to make sure that no flows with
> non-local source IP addresses are routed. Unfortunately this check
> makes it completely impossible to use non-local bound sockets as no
> outbound packets will make through the stack.
> 
> This patch moves the interface lookup to the multicast-specific code
> path as that is the only real user of the interface data looked up.
> 
> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
> 
> ---
> 
>  net/ipv4/route.c |   13 +++++--------
>  1 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 537b976..bb1158a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2498,11 +2498,6 @@ #endif
>  		    ZERONET(oldflp->fl4_src))
>  			goto out;
>  
> -		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
> -		dev_out = ip_dev_find(oldflp->fl4_src);
> -		if (dev_out == NULL)
> -			goto out;
> -

I'm not sure how exactly this is used by applications, but couldn't you
restrict this to sockets without freebind?
