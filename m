From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] net: dst_release() cleanup
Date: Mon, 7 Dec 2009 20:59:00 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912072056350.27565@melkinpaasi.cs.helsinki.fi>
References: <4B1A4BC5.3050300@gmail.com> <20091207091746.51d8958a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34102 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758492AbZLGS64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 13:58:56 -0500
In-Reply-To: <20091207091746.51d8958a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Dec 2009, Stephen Hemminger wrote:

> On Sat, 05 Dec 2009 13:02:13 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > atomic_dec_return() is a full memory barrier, we can omit
> > the smp_mb__before_atomic_dec() call.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/core/dst.c |    9 ++-------
> >  1 file changed, 2 insertions(+), 7 deletions(-)
> > 
> > diff --git a/net/core/dst.c b/net/core/dst.c
> > index 57bc4d5..cdec1d1 100644
> > --- a/net/core/dst.c
> > +++ b/net/core/dst.c
> > @@ -262,13 +262,8 @@ again:
> >  
> >  void dst_release(struct dst_entry *dst)
> >  {
> > -	if (dst) {
> > -               int newrefcnt;
> > -
> > -		smp_mb__before_atomic_dec();
> > -               newrefcnt = atomic_dec_return(&dst->__refcnt);
> > -               WARN_ON(newrefcnt < 0);
> > -	}
> > +	if (dst)
> > +		WARN_ON(atomic_dec_return(&dst->__refcnt) < 0);
> >  }
> >  EXPORT_SYMBOL(dst_release);
> 
> I don't like to put actual necessary code in WARN or BUG macro
> args because some embedded type developer is likely to build
> with
> 
> #define WARN_ON(x)
> 
> to get rid of all warnings.

That's their problem then to fix all relevant places. ...That won't even 
compile because of constructs like this:

	if (WARN_ON(x))

...To my knowing this perfectly legal way of doing this.

-- 
 i.
