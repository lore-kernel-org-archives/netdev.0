From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Mon, 01 Oct 2007 20:50:50 -0700 (PDT)
Message-ID: <20071001.205050.66151815.davem@davemloft.net>
References: <20071002005917.GB5480@bitmover.com>
	<alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>
	<20071002022059.GE7037@bitmover.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, wscott@bitmover.com,
	netdev@vger.kernel.org
To: lm@bitmover.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751758AbXJBDuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:50:50 -0400
In-Reply-To: <20071002022059.GE7037@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lm@bitmover.com (Larry McVoy)
Date: Mon, 1 Oct 2007 19:20:59 -0700

> A short summary is "can someone please post a test program that sources
> and sinks data at the wire speed?"  because apparently I'm too old and
> clueless to write such a thing.

You're not showing us your test program so there is no way we
can help you out.

My initial inclination, even without that critical information,
is to ask whether you are setting any socket options in way?

In particular, SO_RCVLOWAT can have a large effect here, if you're
setting it to something, that would explain why dd is doing better.  A
lot of people link to "helper libraries" with interfaces to setup
sockets with all sorts of socket option settings by default, try not
using such things if possible.

You also shouldn't dork at all with the receive and send buffer sizes.
They are adjusted dynamically by the kernel as the window grows.  But
if you set them to specific values, this dynamic logic is turned off.
