From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] atm: br2684: Fix excessive queue bloat
Date: Mon, 26 Nov 2012 00:52:10 +0100
Message-ID: <20121125235210.GA17935@shrek.podlesie.net>
References: <1353715292.26346.237.camel@shinybook.infradead.org>
 <20121125214332.GA2722@shrek.podlesie.net>
 <1353880892.26346.300.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Crispin <blogic@openwrt.org>,
	Dave =?iso-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>,
	"Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [93.179.225.50] ([93.179.225.50]:59991 "EHLO shrek.podlesie.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab2KYXwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 18:52:12 -0500
Content-Disposition: inline
In-Reply-To: <1353880892.26346.300.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 25, 2012 at 10:01:32PM +0000, David Woodhouse wrote:
> 
> Yeah. This is fairly much the same conversation I ended up having when I
> did the same for PPPoATM.
> 
> Some day *perhaps* we might look at doing something adaptive, so it'll
> detect a TX underrun and increase the amount of buffering. But this
> seems perfectly good for now.

The biggest problem is the existence of additional, mostly unnecessary
huge software queue that we have between us and the hardware on "ATM sockets".
Most of ATM drivers have some hardware queue, but accept and queue
additional frames in software and it just adds unnecessary delay
- it's much better to queue those frames in netdev queue. With this patch
we limit this queue by limiting the number of frames in this queue and
hardware queue to 2 frames, but the hardware may require larger *hardware*
queue to saturate the link. If we had only the hardware queue, the queue
would be probably sized adequately in ATM driver or could be tuned by user.

I think that the 2 frame queue is much better than the huge queue,
that we have now.

> 
> > Maybe this magic "2" and the comment should be moved to some #define.
> 
> Doesn't make it any less magic. I'm happier with it as it is, with a
> clear comment describing why it's done that way.
> 

In PPPoATM we have NONE_INFLIGHT.

Krzysiek
