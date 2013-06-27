From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 3/5] inetpeer: use generic union inet_addr
Date: Thu, 27 Jun 2013 01:01:22 -0700
Message-ID: <1372320082.3301.217.camel@edumazet-glaptop>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372315398-19683-4-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/net/inetpeer.h |   29 +++++----------
>  net/ipv4/inetpeer.c    |   35 +++++++++++-------
>  net/ipv4/tcp_metrics.c |   92 ++++++++++++++++++++----------------------------
>  3 files changed, 68 insertions(+), 88 deletions(-)
> 
> diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
> index 53f464d..7ec33fb 100644
> --- a/include/net/inetpeer.h
> +++ b/include/net/inetpeer.h
> @@ -13,24 +13,13 @@
>  #include <linux/spinlock.h>
>  #include <linux/rtnetlink.h>
>  #include <net/ipv6.h>
> +#include <net/inet_addr.h>
>  #include <linux/atomic.h>
>  
> -struct inetpeer_addr_base {
> -	union {
> -		__be32			a4;
> -		__be32			a6[4];
> -	};
> -};
> -
> -struct inetpeer_addr {
> -	struct inetpeer_addr_base	addr;
> -	__u16				family;
> -};
> -
>  struct inet_peer {
>  	/* group together avl_left,avl_right,v4daddr to speedup lookups */
>  	struct inet_peer __rcu	*avl_left, *avl_right;
> -	struct inetpeer_addr	daddr;
> +	union inet_addr		daddr;

Please compare sizeof(struct inetpeer_addr) and sizeof(union inet_addr)

If I am not mistaken, its 20 bytes instead of 28

Yes, sockaddr_in6 is a bit bloated...
