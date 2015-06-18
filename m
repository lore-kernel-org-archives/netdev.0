From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH RFC] tun, macvtap: higher order allocations for skbs
Date: Thu, 18 Jun 2015 12:54:44 +0200
Message-ID: <5582A374.6020402@de.ibm.com>
References: <1434622758-16549-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434622758-16549-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.06.2015 um 12:20 schrieb Michael S. Tsirkin:
> Needs more testing. Anyone see anything wrong with this?
Can you explain the motivation? 
FWIW, basic networking between two guest over macvtap still
seems to work on s390 so I dont see any obvious regression.

Christian

> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/macvtap.c | 2 +-
>  drivers/net/tun.c     | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 928f3f4..80e87e4 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -610,7 +610,7 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
>  		linear = len;
> 
>  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
> -				   err, 0);
> +				   err, 1);
>  	if (!skb)
>  		return NULL;
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index cb376b2d..8f2f1e5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1069,7 +1069,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
>  		linear = len;
> 
>  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
> -				   &err, 0);
> +				   &err, 1);
>  	if (!skb)
>  		return ERR_PTR(err);
> 
