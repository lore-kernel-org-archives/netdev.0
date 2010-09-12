From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 22:45:52 +0200
Message-ID: <20100912204552.GA2585@del.dom.local>
References: <20100911123140.GA1939@del.dom.local>
 <20100911.203002.193707453.davem@davemloft.net>
 <20100912104534.GA2056@del.dom.local>
 <20100912.085833.226777368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64943 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab0ILUp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 16:45:59 -0400
Received: by wyf22 with SMTP id 22so5390789wyf.19
        for <netdev@vger.kernel.org>; Sun, 12 Sep 2010 13:45:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100912.085833.226777368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 12, 2010 at 08:58:33AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 12 Sep 2010 12:45:34 +0200
> 
> > Then a few more questions:
> > 1) if doubly linked lists really require such pskb_copying, isn't it
> >    all too costly?
> 
> In the common case the data reference will be one, so we will not
> copy.

Even if so, one such a case on the fast path should hit performance,
so it would need special reviewing.

> 
> > 2) why skb_clone isn't enough instead of pskb_copy?
> 
> Can't share the metadata.

I'd really like to understand why the change in handling next/prev
should affect more than skb pointers wrt. current sharing.

> 
> > 3) since skb_clone has some cost too, why e.g. saving only the pointer
> >    to the tail of the list in skb_shared_info isn't enough?
> 
> Then we won't get the rest of the advantages of using list_head such
> as prefetching during traversals, automatic debugging facilities, et al.

Right, we need to sum pros and cons. So, what's the pros? ;-)

Jarek P.
