From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Wed, 5 Feb 2014 00:32:06 +0100
Message-ID: <20140204233206.GA16198@order.stressinduktion.org>
References: <20140118191107.GA21979@sesse.net> <20140119181806.GC16462@order.stressinduktion.org> <20140120184025.GA19972@sesse.net> <20140130104709.GA21178@sesse.net> <20140130180304.GA3793@plex.lan> <20140130181229.GA32245@sesse.net> <20140130224411.GG25336@order.stressinduktion.org> <20140204220809.GB7526@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58967 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932933AbaBDXcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 18:32:08 -0500
Content-Disposition: inline
In-Reply-To: <20140204220809.GB7526@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 11:08:09PM +0100, Steinar H. Gunderson wrote:
> On Thu, Jan 30, 2014 at 11:44:11PM +0100, Hannes Frederic Sowa wrote:
> > The routing lookup is done at IP_ADD_MEMBERSHIP time. I really wonder why you
> > have routed the 239.0.0.0/8 range to eth0.11. It seems to me that the kernel
> > does what you told it to do. ;)
> > 
> > multicast flag on ip route is just used for multicast forwarding and does not
> > matter for local multicast. Also if we find unicast route first (more
> > specific) kernel does not do backtracking if destination is in multicast
> > scope.
> 
> Hah, you're right. The issue was a combination of:

Thanks for letting me know!

>  1. mediatomb's initscript on Debian at some point started to add a bogus
>     239.0.0.0/8 route (and I didn't notice this because I earlier tested with
>     addresses outside this range).
>  2. I didn't properly understand that the multicast flag on the route did not
>     matter (although it really should!).

Hmm, maybe that would be good but I am not sure if that could break existing
setups if we change that now. It seems it is handled like that since Alexey
implemented it in that way.

Greetings,

  Hannes
