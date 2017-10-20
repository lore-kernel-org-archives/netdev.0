From: Kevin Dawson <kevind@esi.com.au>
Subject: Re: [PATCH 2/2] net: netrom: refactor code in nr_add_node
Date: Sat, 21 Oct 2017 10:09:42 +1100
Message-ID: <20171020230942.GA6843@auricle.kd>
References: <20171019172746.GA15332@embeddedor.com>
 <59E9BA66.4000707@bfs.de>
 <20171020110600.Horde.X15IwxxrG50sNBWbTzaM1pB@gator4166.hostgator.com>
 <59EA2A2D.4040003@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from teparybean2.exetel.com.au ([220.233.0.94]:58777 "EHLO
        teparybean2.exetel.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753267AbdJTXZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 19:25:39 -0400
Content-Disposition: inline
In-Reply-To: <59EA2A2D.4040003@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.

My original response just went to Gustavo and Walter because I'm not much of a kernel hacker these days; it was mainly observations that may or may not have been helpful and I'm not a regular list contributor.  Looks like I shouldn't have been so shy!

On Fri, Oct 20, 2017 at 06:54:05PM +0200, walter harms wrote:
> 
> ...
> 
> >> From the code below i can see: y=x+1 Perhaps that can be used.
> > 
> > So are you proposing to use two arguments instead of three?
> > 
> > re_sort_routes(nr_node, 0);
> 
> I am not sure, i would wait a bit and see if what improves readability.
> as Kevin Dawson pointed out: this is a sort here.
> Maybe there a nice way to do something like that (i do not know):
> 
> case 3:
>   re_sort_routes(nr_node, 1,2)
> case 2:
>   re_sort_routes(nr_node, 0,1)
> case 1:
>   break;

Nearly - you left out one of the calls to re_sort_routes.  I include my original mail here, as it explains it better:

> Hi Walter and Gustavo.
> 
> I've just left this response for the two of you, as it's a long time since I've been fiddling in the kernel and I don't know much of the current ideology regarding how people want their coding done.
> 
> I also only have a passing knowledge of NetRom, but I do recall some of the principles like routes and their quality.
> 
> On Fri, Oct 20, 2017 at 10:57:10AM +0200, walter harms wrote:
> > 
> > Am 19.10.2017 19:27, schrieb Gustavo A. R. Silva:
> > > Code refactoring in order to make the code easier to read and maintain.
> 
> ...
> 
> [ Gustavo ]
> > > +/*      re-sort the routes in quality order.    */
> > > +static inline void re_sort_routes(struct nr_node *nr_node, int ix_x, int ix_y)
> 
> I'm curious as to why re_sort_routes() is declared inline.  Its use below hardly gains any efficiency from saving function calls; as well, it's extra code space taken.
> 
> > > +		if (nr_node->which == ix_x)
> > > +			nr_node->which = ix_y;
> > > +		else if (nr_node->which == ix_y)
> > > +			nr_node->which = ix_x;
> 
> I suspect this can be simplified too, but I don't know what the possible values for ->which might be in any particular route case.
> 
> ...
> 
> [ Walter ]
> > From the code below i can see: y=x+1 Perhaps that can be used.
> > ...
> > >  	/* Now re-sort the routes in quality order */
> > >  	switch (nr_node->count) {
> > >  	case 3:
> > >  		re_sort_routes(nr_node, 0, 1);
> > >  		re_sort_routes(nr_node, 1, 2);
> > >  		/* fall through */
> > >  	case 2:
> > >  		re_sort_routes(nr_node, 0, 1);
> > >  	case 1:
> > >  		break;
> > >  	}
> 
> Yes, it can and it makes sense to do so.  The algorithm is an unrolled bubblesort for up to 3 routes.  If 3 is as far as it will ever go (and given that's all the original function allowed for), it's not unjustified in leaving it that way.  Anything more and I'd be suggesting it be made a loop.
> 
> > kernel.h has a swap() macro. so you can swap(nr_node->routes[x],nr_node->routes[y]);
> 
> I presume the swap() macro handles arbitrary types - structs and not just ints.  If the aim is to improve readability of the code, it helps.
> 
> I hope I'm not completely out of line in suggesting this.  As I say, it's been quite a while since I've dabbled in the kernel (although I did start back in the 1970s on Unix...).
> 
> Thanks,
> Kevin
