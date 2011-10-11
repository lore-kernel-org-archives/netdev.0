From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Tue, 11 Oct 2011 15:34:11 +0200
Message-ID: <20111011133411.GA2545@netboy.at.omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
 <20111007.133356.489094996618032061.davem@davemloft.net>
 <20111008075719.GA2284@netboy.at.omicron.at>
 <1318061808.3991.12.camel@jlt3.sipsolutions.net>
 <1318064238.5276.2.camel@edumazet-laptop>
 <1318069935.3991.25.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39577 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab1JKNeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 09:34:15 -0400
Received: by ywb5 with SMTP id 5so6541718ywb.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 06:34:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318069935.3991.25.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 08, 2011 at 12:32:15PM +0200, Johannes Berg wrote:
> On Sat, 2011-10-08 at 10:57 +0200, Eric Dumazet wrote:
> > Check following commit changelog to get some information on this.
> > 
> > commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Thu Jun 11 02:55:43 2009 -0700
> > 
> >     net: No more expensive sock_hold()/sock_put() on each tx
...
> There's one thing I still miss though: It seems to me that if you have a
> reference to a socket that has been sk_free()'ed (which is possible
> since it might still have sk_wmem_alloc > 0) you can't sock_hold() that
> socket. That feels a bit unexpected -- and might happen in the code
> Richard just suggested.

Yes, I have been trying to see how to solve this, but it looks like I
am out of luck. 

Even if I use skb_set_owner_w() in skb_clone_tx_timestamp(), still the
sock might go away during skb_orphan() in sock_queue_err_skb().

It is no good to take sock_hold() in skb_complete_tx_timestamp(),
since, as you point out, it might not be safe to call.

So, I wonder, when is it safe to call sock_hold?

Are the 101 odd callers protected against the situation where the last
sock_out() has already happened?

Thanks,

Richard
