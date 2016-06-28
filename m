From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: increase size at which
 tcp_bound_to_half_wnd bounds to > TCP_MSS_DEFAULT
Date: Wed, 29 Jun 2016 00:35:42 +0200
Message-ID: <1467153342.6850.205.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CS1PR84MB0295E420892A535E40FE338EFD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
	 <1467115090.6850.202.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Seymour, Shane M" <shane.seymour@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36219 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbcF1Wf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 18:35:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id c82so9695696wme.3
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 15:35:44 -0700 (PDT)
In-Reply-To: <CS1PR84MB02950F38FF1801E89612B9E4FD220@CS1PR84MB0295.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-28 at 21:54 +0000, Seymour, Shane M wrote:
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Trying to cope with ridiculous windows these days is really a waste of
> > time, as we perform this check for all tcp sendmsg() calls :(
> 
> I don't disagree with you but unfortunately there are still devices
> out there like this and probably will be for a long time.
> 
> > Anyway, your patch is reversed.
> 
> I'm not sure what you mean by reversed, I didn't change the direction
> of the test in the code just what it's being compared against and so
> it's greater than not greater than or equal to.
> 
> Unless auto-correction changed reviewed to reversed?

Your diff is reversed. You sent :

--- b/include/net/tcp.h 2016-06-23 20:59:14.521686048 -0500
+++ a/include/net/tcp.h 2016-06-15 17:19:21.964821477 -0500
@@ -589,7 +589,7 @@ static inline int tcp_bound_to_half_wnd(
         * On the other hand, for extremely large MSS devices, handling
         * smaller than MSS windows in this way does make sense.
         */
-       if (tp->max_window > TCP_MSS_DEFAULT)
+       if (tp->max_window >= 512)
                cutoff = (tp->max_window >> 1);
        else
                cutoff = tp->max_window;



You meant instead :

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0bcc70f4e1fb..8dafd2c31b1d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -589,7 +589,7 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 	 * On the other hand, for extremely large MSS devices, handling
 	 * smaller than MSS windows in this way does make sense.
 	 */
-	if (tp->max_window >= 512)
+	if (tp->max_window > TCP_MSS_DEFAULT)
 		cutoff = (tp->max_window >> 1);
 	else
 		cutoff = tp->max_window;
