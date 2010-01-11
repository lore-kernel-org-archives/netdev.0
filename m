From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
 interface
Date: Mon, 11 Jan 2010 17:21:48 -0600
Message-ID: <1263252108.29868.4774.camel@calx>
References: <4B44F895.9080205@gmail.com>	<1262836445.29868.227.camel@calx>
	 <20100107.010201.51693251.davem@davemloft.net> <4B4630C0.6090206@gmail.com>
	 <4B467A4D.9070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	jmoyer@redhat.com, netdev@vger.kernel.org, netdev@oss.sgi.com
To: Daniel Borkmann <danborkmann@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:34615 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab0AKXVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 18:21:53 -0500
In-Reply-To: <4B467A4D.9070708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-08 at 01:20 +0100, Daniel Borkmann wrote:
> Daniel Borkmann wrote:
> > David Miller wrote:
> >> From: Matt Mackall <mpm@selenic.com>
> >> Date: Wed, 06 Jan 2010 21:54:05 -0600
> >>
> >>> Please inline patches so they can be reviewed easily in reply.
> >>>
> >>>
> >>> -       struct netpoll *np = npi->rx_np;
> >>> +       struct netpoll **np = &npi->rx_np;
> >>>  
> >>> -       if (!np)
> >>> +       if (!(*np))
> >>>
> >>> This makes everything horrible. Can you avoid the double indirection?
> >>> Using a list head might be a good answer.
> >>>
> >> Agreed on all counts.
> >>
> > 
> > Agreed on the double indirection, I'll fix it.
> > 
> > I've already considered the list_head structure, but then I was the opinion
> > that a double linked list might not be necessary for this, so I did it that
> > way ... (compare: kernel notifier by Alan Cox). If you insist on that I'll
> > fix it of course ;)
> 
> So, here's the list head implementation. Tested on both of my machines with several
> rx_hook clients.

Looks pretty good. Dave?

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
http://selenic.com : development and support for Mercurial and Linux


