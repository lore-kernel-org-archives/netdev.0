From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Sat, 19 May 2007 22:20:14 -0700
Message-ID: <20070519222014.45f11138@freepuppy>
References: <464B7127.5080502@gmail.com>
	<20070518180903.GC3492@tuxdriver.com>
	<1179622601.9453.4.camel@xo-28-0B-88.localdomain>
	<464FA894.8090008@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <464FA894.8090008-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 19 May 2007 21:47:00 -0400
Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org> wrote:

> Dan Williams wrote:
> > On Fri, 2007-05-18 at 14:09 -0400, John W. Linville wrote:
> >> On Wed, May 16, 2007 at 05:01:27PM -0400, Florin Malita wrote:
> >>> In libertas_process_rxed_packet() and process_rxed_802_11_packet() the 
> >>> skb is dereferenced after being passed to netif_rx (called from 
> >>> libertas_upload_rx_packet). Spotted by Coverity (1658, 1659).
> >>  
> >> Relocating the libertas_upload_rx_packet call is fine, but...
> >>
> >>> Also, libertas_upload_rx_packet() unconditionally returns 0 so the error 
> >>> check is dead code - might as well take it out.
> >> Is this merely an implementation detail?  Or an absolute fact?
> >> If the former is true, then we should preserve the error
> >> checking.  If the latter, then we should change the signature of
> >> libertas_upload_rx_packet to return void.
> > 
> > According to the comments, netif_rx always succeeds.  I think we should
> > just change the return type to void since there's nothing else in that
> > function that can fail.
> 
> According to the implementation, netif_rx() can fail.
> 
> 	Jeff

Yeah, it was the old congestion levels that got dropped.
The skb is always consumed so the the return value is informational only.


-- 
Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
