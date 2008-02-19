From: Glenn Griffin <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH 1/3] Support arbitrary initial TCP timestamps
Date: Tue, 19 Feb 2008 10:02:38 -0800
Message-ID: <47bb17d7.28d7720a.526b.6a8e@mx.google.com>
References: <20080218164723.GA13941@fin>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:25489 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774AbYBSRyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 12:54:38 -0500
Received: by wr-out-0506.google.com with SMTP id c48so2122769wra.23
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 09:54:33 -0800 (PST)
In-Reply-To: <20080218164723.GA13941@fin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Adding yet another member to the already bloated tcp_sock structure to
> > implement this is too high a cost.
> 
> Yes, I was worried that would be deemed too high of a cost, but it was
> the most efficient way I could think to accomplish what I wanted.
> 
> > I would instead prefer that there be some global random number
> > calculated when the first TCP socket is created, and use that as a
> > global offset.  You can even recompute it every few hours if you
> > like.
> 
> That would work fine if my mine purpose was to randomize the tcp
> timestamp to mitigate the leak in information regarding uptime, but
> despite the brief description, that's only a side effect of what I
> intended to do.  What I wanted was a way to be able to choose an initial
> tcp timestamp for a particular connection that was not tied directly to
> jiffies.
> 
> The two patches following this show my intended use case.  I intend to
> enhance syncookie support to allow it to support advanced tcp options
> (sack and window scaling).  Normally syncookies encode the bare minimum
> state of a connection in the ISN they choose, but the 32bit ISN isn't
> enough to encode advanced tcp options so you are left with a working but
> crippled tcp stack during a synflood attack.  If in addition to choosing
> an ISN we are able to choose an initial tcp timestamp, we are then able
> to encode an additional 32 bits of information that can contain more of
> the advanced tcp options.

Perhaps I should clarify.  I don't see a way to implement the additional
syncookie enhancements without storing an offset in some type of
per-socket structure.  Given that, is it still deemed too high of a cost?
Is enhancing syncookies not deemed important enough to warrant the
additional 4 bytes?  What if there was an additional config variable to
support arbitrary/random tcp timestamps, and then syncookies only used
the additional options when that setting was chosen?  Is there some
possiblity I'm missing that could get this feature in a form suitable
for inclusion?  Thanks.

--Glenn

