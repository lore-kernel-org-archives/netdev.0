From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Tue, 4 Jan 2011 13:19:44 +0100
Message-ID: <20110104121944.GB332@e-circ.dyndns.org>
References: <20101223093627.GA325@e-circ.dyndns.org>
	<20101223094302.GB325@e-circ.dyndns.org>
	<4D135BC3.6070707@pengutronix.de>
	<20101224091428.GA375@e-circ.dyndns.org>
	<4D148788.3010808@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D148788.3010808-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Fri, Dec 24, 2010 at 12:44:08PM +0100, Marc Kleine-Budde wrote:
> 
> >> hmmm..all stuff behind dpram is __iomem, isn't it? I think it should
> >> only be accessed with via the ioread/iowrite operators. Please check
> > I did an ioremap_nocache. Since it is unaligned, ioread/iowrite would render
> > a lot of statements.
> 
> The thing is, ioremapped mem should not be accessed directly. Instead
> ioread/iowrite should be used. The softing driver should work on non x86
> platforms, too.
> 
> >> your code with sparse (compile with "make C=2").
> > (?)
> 
> Sparse, a static syntax analyser tool, see "Documentation/sparse.txt".
> It throws the following warnings on your driver:
> 
> > make drivers/net/can/softing/softing.ko C=2
> >   CHK     include/linux/version.h
> >   CHK     include/generated/utsrelease.h
> >   CALL    scripts/checksyscalls.sh
> >   CHECK   scripts/mod/empty.c
> >   CHECK   drivers/net/can/softing/softing_main.c
> > drivers/net/can/softing/softing_main.c:98:15: warning: incorrect type in argument 1 (different address spaces)
> > drivers/net/can/softing/softing_main.c:98:15:    expected void volatile [noderef] <asn:2>*dst
> > drivers/net/can/softing/softing_main.c:98:15:    got unsigned char [usertype] *[assigned] ptr
[...]
> 
> You should start with fixing the assignment of the ioremapped memory
> (drivers/net/can/softing/softing_main.c:835), the fix the rest.
> 
(Thanks for the explanation)^2.

I left my code now with the only warning from sparse:
warning: Using plain integer as NULL pointer

That means, I got all __iomem references fixed.
Is this '0' instead of 'NULL' a big problem? I got plenty of those.

Kurt
