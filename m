From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 09:28:45 +0200
Message-ID: <20070514072845.GA2081@ff.dom.local>
References: <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org> <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54711 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752820AbXENHWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 03:22:13 -0400
Content-Disposition: inline
In-Reply-To: <20070513.233937.99203647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 13, 2007 at 11:39:37PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 14 May 2007 08:07:00 +0200
> 
> > After sending this patch I was a little confused, when next
> > lockdep warning report appeared, and I thought - since this is 
> > not enough, this patch could be dumped. But now I changed my
> > mind: there are really many possibilities of strange connections
> > between locks taken from vlans, ppp (with pppoe), multicasts etc.
> > - that every one possibility less is a gain here.
>  ...
> > Of course, later, if somebody will find better solution, they could
> > be removed,
> 
> I already suggested a better fix, you ignored it.

No, I couldn't have ignored any of your suggestions (I would've
written about any doubts, anyway). I simply misunderstood! I
thought you mean different classes for netdevs used in vlan,
and I prepared such a patch... Sorry!

> 
> For each unique netdev type, use a different locking class.
> 
> That will fix this forever, anything else is a situation specific
> band-aid (but then again isn't that what every lockdep annotation is
> :-).

Yes, this is very good idea, and I wonder, why you didn't try
this yourself (after my "ignore"). I thought a little about
this, but was afraid of it's wide range. Some things - like
in vlans - should be removed then, for this to work. I'll try
to send something like this soon (but I'm not so optimistic
it will cure all or forever...).

Regards,
Jarek P.
