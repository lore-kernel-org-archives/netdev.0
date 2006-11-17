From: Dave Dillow <dave@thedillows.org>
Subject: Re: d80211: clean up some list and loop code
Date: Thu, 16 Nov 2006 21:37:57 -0500
Message-ID: <1163731077.27623.2.camel@obelisk.thedillows.org>
References: <1163718270.3392.19.camel@johannes.berg>
	 <20061116232455.GA3297@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:12698 "EHLO smtp.knology.net")
	by vger.kernel.org with ESMTP id S1162326AbWKQCiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 21:38:03 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061116232455.GA3297@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-16 at 18:25 -0500, John W. Linville wrote:
> On Fri, Nov 17, 2006 at 12:04:29AM +0100, Johannes Berg wrote:
> > Remove things like "for (;;)" or "for (; condition ;)".
> > Ever heard of while loops?
> 
> > --- wireless-dev.orig/net/d80211/sta_info.c	2006-11-16 23:40:48.164935990 +0100
> > +++ wireless-dev/net/d80211/sta_info.c	2006-11-16 23:55:34.634935990 +0100
> > @@ -299,7 +299,7 @@ static void sta_info_cleanup_expire_buff
> >  	if (skb_queue_empty(&sta->ps_tx_buf))
> >  		return;
> >  
> > -	for (;;) {
> > +	while (1) {
> >  		spin_lock_irqsave(&sta->ps_tx_buf.lock, flags);
> >  		skb = skb_peek(&sta->ps_tx_buf);
> >  		if (sta_info_buffer_expired(local, sta, skb)) {
> 
> FWIW, I think I prefer the "for (;;)" version for endless loops.
> It looks more intentional to me.  Some grep'ing showed nearly equal
> usage of "for (;;)" versus "while (1)".  Is there any "official"
> preference?  I don't see anything in CodingStyle about it.

I don't know about official preference, but in ages past, using
"for(;;)" was preferable because "while(1)" would often invoke a
"statement has no effect" warning from the compiler. gcc 4.0.2 doesn't
have this problem, but IIRC it used to.

FWIW, I prefer "for(;;)" because of painful memories with other people's
code and -Werror, but I don't barf at "while(1)".
