From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 19:53:10 +0200
Message-ID: <1318009990.3988.36.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <1318009222.3988.28.camel@jlt3.sipsolutions.net>
	 <1318009644.3988.33.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50279 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab1JGRxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:53:13 -0400
In-Reply-To: <1318009644.3988.33.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 19:47 +0200, Johannes Berg wrote:

> I'm afraid as is this is terminally broken. I don't have a device with a
> dp83640 PHY, but I bet you can cause kernel crashes by doing something
> like
> 
> while (1)
> 	fd = open()
> 	enable tx timestamping on fd;
> 	send(fd, frame)
> 	close(fd);

It's possible that it doesn't crash *if* (and only if!) the ethernet
driver is guaranteed to process the TXTS RX packet before freeing the
original SKB off the TX queue, and also never orphans or whatever the
original TX SKB. In that case the original TX SKB will hang on to the
socket for long enough I guess.

But that's not something I'd want to rely on. All it means that the
above code isn't an instant kernel crash. The code is still broken.

johannes
