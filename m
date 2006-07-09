From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 9 Jul 2006 16:19:33 +0200
Message-ID: <20060709141933.GM14627@postel.suug.ch>
References: <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch> <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch> <1152449536.5124.31.camel@jzny2> <20060709133327.GK14627@postel.suug.ch> <1152453796.5124.70.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48609 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932255AbWGIOTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 10:19:13 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152453796.5124.70.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-09 10:03
> On Sun, 2006-09-07 at 15:33 +0200, Thomas Graf wrote:
> > That's not gonna work, dev->queue_lock may be held legimitately
> > by someone else than an underlying dev_queue_xmit() call.
> > 
> 
> If there is a legitimate reason then it wont work. I cant think of one
> though.

See sch_generic.c, it's documented. A simple grep on queue_lock
would have told you the same.

> This is also another approach that would work. If you think its simpler
> go ahead and shoot a patch.

It's not simpler, it's correct, while your patch is wrong.

> A->*->A is a no-no.
> And in some cases it is fine to let the user just fsck themselves
> because then they will understand it is a bad idea [1] when shit
> happens. OTOH, if there was a KISS way of doing it (as in the ifb case,
> why not).

I remind you that you started mentioning this A->*->A case while
talking about tx deadlocks that were supposed to be prevented with
the !from check or something along that lines. I can't really tell
because you explain it differently in every posting.

> Yes, of course otherwise i wouldnt bother to comment on any patches.

So maintain the code and fix your bugs.
