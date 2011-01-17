From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost-net: use lock_sock_fast() in peek_head_len()
Date: Mon, 17 Jan 2011 11:57:38 +0200
Message-ID: <20110117095738.GG23479@redhat.com>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
 <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110117081117.18900.48672.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 04:11:17PM +0800, Jason Wang wrote:
> We can use lock_sock_fast() instead of lock_sock() in order to get
> speedup in peek_head_len().
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Queued for 2.6.39, thanks everyone.

> ---
>  drivers/vhost/net.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index c32a2e4..50b622a 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -211,12 +211,12 @@ static int peek_head_len(struct sock *sk)
>  {
>  	struct sk_buff *head;
>  	int len = 0;
> +	bool slow = lock_sock_fast(sk);
>  
> -	lock_sock(sk);
>  	head = skb_peek(&sk->sk_receive_queue);
>  	if (head)
>  		len = head->len;
> -	release_sock(sk);
> +	unlock_sock_fast(sk, slow);
>  	return len;
>  }
>  
