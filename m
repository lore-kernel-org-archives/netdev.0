From: Andrei Emeltchenko <andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net, bluetooth: don't attempt to free a channel that
 wasn't created
Date: Fri, 5 Oct 2012 13:22:00 +0300
Message-ID: <20121005102159.GF12229@aemeltch-MOBL1>
References: <1349395197-12395-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1349395197-12395-1-git-send-email-sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

On Thu, Oct 04, 2012 at 07:59:57PM -0400, Sasha Levin wrote:
> We may currently attempt to free a channel which wasn't created due to
> an error in the initialization path, this would cause a NULL ptr deref.

Please put oops dump here.

> Introduced in commit 61d6ef3e ("Bluetooth: Make better use of l2cap_chan
> reference counting").
> 
> Signed-off-by: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  net/bluetooth/l2cap_sock.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index 083f2bf..66c295a 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -1083,7 +1083,8 @@ static void l2cap_sock_destruct(struct sock *sk)
>  {
>  	BT_DBG("sk %p", sk);
>  
> -	l2cap_chan_put(l2cap_pi(sk)->chan);
> +	if (l2cap_pi(sk)->chan)
> +		l2cap_chan_put(l2cap_pi(sk)->chan);

This does not look right, I suppose you want to put somewhere missing
chan_hold

>  	if (l2cap_pi(sk)->rx_busy_skb) {
>  		kfree_skb(l2cap_pi(sk)->rx_busy_skb);
>  		l2cap_pi(sk)->rx_busy_skb = NULL;
> -- 
> 1.7.12

Best regards 
Andrei Emeltchenko 
