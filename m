From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Fri, 18 May 2007 14:09:03 -0400
Message-ID: <20070518180903.GC3492@tuxdriver.com>
References: <464B7127.5080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <464B7127.5080502-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2007 at 05:01:27PM -0400, Florin Malita wrote:
> In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
> skb is dereferenced after being passed to netif_rx (called from 
> libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).
 
Relocating the libertas_upload_rx_packet call is fine, but...

> Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
> check is dead code - might as well take it out.

Is this merely an implementation detail?  Or an absolute fact?
If the former is true, then we should preserve the error
checking.  If the latter, then we should change the signature of
libertas_upload_rx_packet to return void.

> Signed-off-by: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> 	lbs_pr_debug(1, "RX Data: size of actual packet = %d\n", skb->len);
> -	if (libertas_upload_rx_packet(priv, skb)) {
> -		lbs_pr_debug(1, "RX error: libertas_upload_rx_packet"
> -		       " returns failure\n");
> -		ret = -1;
> -		goto done;
> -	}
> 	priv->stats.rx_bytes += skb->len;
> 	priv->stats.rx_packets++;
> 
> +	libertas_upload_rx_packet(priv, skb);
> +
> 	ret = 0;
> done:
> 	LEAVE();

Another potential patch is to remove the "ret = 0" line before the
"done" label, since ret is initialized at the head of the function.
Come to think of it, you can probably remove the "= 0" part of ret's
declaration as well (in both functions).

Hth!

John

P.S.  Also, please make sure to send wireless patches to
linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org and CC me.
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
