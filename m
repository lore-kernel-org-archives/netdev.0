From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Fri, 13 Aug 2010 17:13:53 +0200
Message-ID: <1281712433.2116.15.camel@jlt3.sipsolutions.net>
References: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	 <1279700420.2452.15.camel@edumazet-laptop>
	 <1279701835.2452.17.camel@edumazet-laptop>
	 <20100725.215548.112589000.davem@davemloft.net>
	 <1281708024.3760.12.camel@jlt3.sipsolutions.net>
	 <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:43118 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab0HMPNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 11:13:55 -0400
In-Reply-To: <1281710887.4470.78.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-13 at 16:48 +0200, Eric Dumazet wrote:

> >                  * If this skb has a frag_list, then here that means that
> >                  * we will have to use the frag_list skb for compat tasks
> >                  * and the regular skb for non-compat tasks.
> >                  *
> >                  * The skb might (and likely will) be cloned, so we can't
> >                  * just reset frag_list and go on with things -- we need to
> >                  * keep that. For the compat case that's easy -- simply get
> >                  * a reference to the compat skb and free the regular one
> >                  * including the frag. For the non-compat case, we need to
> >                  * avoid sending the frag to the user -- so assign NULL but
> >                  * restore it below before freeing the skb.
> > 
> > and that's no longer true, afaict.
> > 
> 
> Comment was not updated by the patch.
> 
> But do you agree temporarly setting frag_list to NULL was a bug ?

No, that was actually intentional, as the comment describes?

> Unfortunatly I cannot test this path...

No wireless devices? :)

> I assume reverting 1235f504aaba removes these errors ?

I haven't tried yet, but it only happened very recently and I didn't
find any other candidate -- the error always points to
wireless_send_event too.

> Its strange we have a double-free on a data part and not a skb_head.

There also was an apparent use-after-free error.

> maybe pskb_copy() has a problem with frag_list...
> 
> 
> Maybe we can revert the patch and find another way to make sure two
> process can not manipulate this skb in // (adding a mutex, or using
> RTNL ?)

I'm getting confused. Why did I think the NULLing and then restoring was
not racy to start with?

johannes

