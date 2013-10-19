From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Sat, 19 Oct 2013 22:24:14 +0200
Message-ID: <20131019202414.GD31333@order.stressinduktion.org>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net> <20131018030440.GI18135@order.stressinduktion.org> <5260D8DE.30303@blub.net> <20131019084225.GA31333@order.stressinduktion.org> <20131019101246.GA27576@sesse.net> <5262963B.8040001@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	"Steinar H. Gunderson" <sgunderson@bigfoot.com>
To: Valentijn Sessink <valentyn@blub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45373 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab3JSUYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 16:24:16 -0400
Content-Disposition: inline
In-Reply-To: <5262963B.8040001@blub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 04:24:59PM +0200, Valentijn Sessink wrote:
> op 19-10-13 12:12, Steinar H. Gunderson schreef:
> >Thanks so much for looking into this! It's great that to hear that it's not
> >just me being weird =)
> 
> I'm not sure the patch addresses weirdness ;-P
> 
> On the more serious side: I have this problem with a 3.8.0 kernel 
> (Ubuntu 12.04 with updated kernel). I saw that you (Steinar) experience 
> this with 3.10 and 3.11, iirc. I'm a little bit worried by the fact that 
> this has not been seen for at least six months - and now suddenly pops up.
> 
> Does anyone have an idea when this race condition was introduced?

Do a bisect. ;)

I had a look at the history but could not find a single commit
to blame. Even reference counting changes (e.g. removal of neighbour
caching in routes) or something in the way the socket release callbacks
are processed by tcp could introduce a way where these problems are more
likely to happen. I wondered, too.

A lot of people of the IPv6 community often state that mtu discovery is broken
because of filtering packet_too_bigs. Maybe most people assumed broken
firewalls and did not actual check if it is the kernels problem. So, thanks
again for reporting this issue.

Greetings,

  Hannes
