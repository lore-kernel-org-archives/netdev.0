From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: Convert skb->csum_(start|offset) integrity BUG_ON()
 to WARN_ON() & drop
Date: Thu, 14 Feb 2013 10:18:53 +0000
Message-ID: <20130214101853.GC21829@casper.infradead.org>
References: <20130213234021.GA21829@casper.infradead.org>
 <20130213234843.GB21829@casper.infradead.org>
 <20130213.193759.1094469499685059296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49144 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933837Ab3BNKS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 05:18:56 -0500
Content-Disposition: inline
In-Reply-To: <20130213.193759.1094469499685059296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/13 at 07:37pm, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 13 Feb 2013 23:48:43 +0000
[...]
> >  b) No longer collapse if the new skb would result in a
> >     a headroom + data that exceeds 64K. This seems to be the
> >     most trivial fix.
[...]
> > Other ideas?
> 
> "b" is a good idea.

OK, patch to do so being tested by original reporter.

> Let's not paper over this, this BUG_ON() is really a BUG_ON()
> meaning "FIX ME NOW" :-)

Maybe it's my general dislike of BUG_ON() in the processing
path, especially if the bug condition can be influenced remotely.
It looks absolutely doable to trigger the previously mentioned
partial acking & collapsing on purpose by a malicious receiver
even with an MTU of 1500. I believe we should avoid total DoS
in future similar situations that we don't think of yet.
