From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Fri, 18 May 2007 22:23:08 -0700
Message-ID: <20070518222308.11c2b34d@localhost>
References: <464B7127.5080502@gmail.com>
	<20070518180903.GC3492@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070518180903.GC3492-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 18 May 2007 14:09:03 -0400
"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:

> On Wed, May 16, 2007 at 05:01:27PM -0400, Florin Malita wrote:
> > In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
> > skb is dereferenced after being passed to netif_rx (called from 
> > libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).
>  
> Relocating the libertas_upload_rx_packet call is fine, but...
> 
> > Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
> > check is dead code - might as well take it out.
> 
> Is this merely an implementation detail?  Or an absolute fact?
> If the former is true, then we should preserve the error
> checking.  If the latter, then we should change the signature of
> libertas_upload_rx_packet to return void.

netif_rx() used to return a value in older kernels.
