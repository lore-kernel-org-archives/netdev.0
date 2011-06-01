From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Wed, 1 Jun 2011 22:04:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1106012201220.5871@ask.diku.dk>
References: <1306948213-20767-4-git-send-email-julia@diku.dk>
	<4DE67CBF.5080006@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: walter harms <wharms-fPG8STNUNVg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DE67CBF.5080006-fPG8STNUNVg@public.gmane.org>
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

On Wed, 1 Jun 2011, walter harms wrote:

> 
> 
> Am 01.06.2011 19:10, schrieb Julia Lawall:
> > From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> > 
> > The failed_get label is used after the call to clk_get has succeeded, so it
> > should be moved up above the call to clk_put.
> > 
> > A simplified version of the semantic match that finds this problem is as
> > follows: (http://coccinelle.lip6.fr/)
> > 
> > // <smpl>
> > @r exists@
> > expression e1,e2;
> > statement S;
> > @@
> > 
> > e1 = clk_get@p1(...);
> > ... when != e1 = e2
> >     when != clk_put(e1)
> >     when any
> > if (...) { ... when != clk_put(e1)
> >                when != if (...) { ... clk_put(e1) ... }
> > * return@p3 ...;
> >  } else S
> > // </smpl>
> > 
> > Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> > 
> > ---
> >  drivers/net/can/flexcan.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> > index d499056..121739c 100644
> > --- a/drivers/net/can/flexcan.c
> > +++ b/drivers/net/can/flexcan.c
> > @@ -978,8 +978,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
> >   failed_map:
> >  	release_mem_region(mem->start, mem_size);
> >   failed_req:
> > -	clk_put(clk);
> >   failed_get:
> > +	clk_put(clk);
> >   failed_clock:
> >  	return err;
> >  }
> > 
> 
> So failed_req == failed_get, is that intended ?

I have the impression that it is.  failed_req comes after successful 
calls to platform_get_resource and platform_get_irq, which don't allocate 
anything.

julia
