From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Wed, 1 Jun 2011 22:13:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1106012212420.5871@ask.diku.dk>
References: <1306948213-20767-4-git-send-email-julia@diku.dk>
	<1306949175.32125.20.camel@Joe-Laptop>
	<Pine.LNX.4.64.1106012207260.5871@ask.diku.dk>
	<20110601.131136.391831410750786951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110601.131136.391831410750786951.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Jun 2011, David Miller wrote:

> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> Date: Wed, 1 Jun 2011 22:08:46 +0200 (CEST)
> 
> > On Wed, 1 Jun 2011, Joe Perches wrote:
> > 
> >> On Wed, 2011-06-01 at 19:10 +0200, Julia Lawall wrote:
> >> > The failed_get label is used after the call to clk_get has succeeded, so it
> >> > should be moved up above the call to clk_put.
> >> []
> >> > diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> >> []
> >> > @@ -978,8 +978,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
> >> >   failed_map:
> >> >  	release_mem_region(mem->start, mem_size);
> >> >   failed_req:
> >> > -	clk_put(clk);
> >> >   failed_get:
> >> > +	clk_put(clk);
> >> >   failed_clock:
> >> >  	return err;
> >> 
> >> If this is correct, it might be better to rename all the
> >> uses of failed_req to failed_get and delete label failed_req.
> > 
> > As I replied to Walter Harms, I believe it is correct, because I don't see 
> > anything in the called functions that needs to be freed.  I can redo the 
> > patch to eliminate the label.
> 
> Please do.

OK, I will do it tomorrow.

julia
