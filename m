From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: d80211: clean up some list and loop code
Date: Thu, 16 Nov 2006 18:25:01 -0500
Message-ID: <20061116232455.GA3297@tuxdriver.com>
References: <1163718270.3392.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:20749 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1424564AbWKPXcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 18:32:21 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163718270.3392.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 17, 2006 at 12:04:29AM +0100, Johannes Berg wrote:
> Remove things like "for (;;)" or "for (; condition ;)".
> Ever heard of while loops?

> --- wireless-dev.orig/net/d80211/sta_info.c	2006-11-16 23:40:48.164935990 +0100
> +++ wireless-dev/net/d80211/sta_info.c	2006-11-16 23:55:34.634935990 +0100
> @@ -299,7 +299,7 @@ static void sta_info_cleanup_expire_buff
>  	if (skb_queue_empty(&sta->ps_tx_buf))
>  		return;
>  
> -	for (;;) {
> +	while (1) {
>  		spin_lock_irqsave(&sta->ps_tx_buf.lock, flags);
>  		skb = skb_peek(&sta->ps_tx_buf);
>  		if (sta_info_buffer_expired(local, sta, skb)) {

FWIW, I think I prefer the "for (;;)" version for endless loops.
It looks more intentional to me.  Some grep'ing showed nearly equal
usage of "for (;;)" versus "while (1)".  Is there any "official"
preference?  I don't see anything in CodingStyle about it.

I agree with the other cleanups.

John
-- 
John W. Linville
linville@tuxdriver.com
