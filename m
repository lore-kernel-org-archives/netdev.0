From: David Miller <davem@davemloft.net>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Fri, 04 Jan 2008 23:25:04 -0800 (PST)
Message-ID: <20080104.232504.238436937.davem@davemloft.net>
References: <477E92B6.8010809@katalix.com>
	<20080104.132443.25068269.davem@davemloft.net>
	<477ECCD7.8090905@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751686AbYAEHZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 02:25:06 -0500
In-Reply-To: <477ECCD7.8090905@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Sat, 05 Jan 2008 00:18:31 +0000

> David Miller wrote:
> > From: James Chapman <jchapman@katalix.com>
> > Date: Fri, 04 Jan 2008 20:10:30 +0000
> > 
> >> With the latest NAPI, this code has to change. But rather than remove
> >> the tx_cleaned logic completely, shouldn't transmit processing be
> >> included in the work_done accounting when a driver does transmit cleanup
> >> processing in the poll?
> > 
> > Most other NAPI drivers don't do this, they just process all the
> > pending TX work unconditionally and do not account it into the NAPI
> > poll work.
> 
> This will cause the interface to thrash in/out of polled mode very
> quickly when it is doing almost all transmit work. That's something to
> avoid, no?

I see your point although I've never seen this in practice
with tg3 or niu.

For a heavy transmit load with TCP, the cpu killer is the ACK receive
processing.

I guess for a datagram send situation it might start to edge up.

However, you're likely deferring TX events (say every 1/4 of the TX
ring or similar) which should make the effect matter much less.

But anyways, it's someone else's driver so if they want to take
TX work into account sure. :-)  I'll keep this in mind in my NAPI
changes.

Thanks.
