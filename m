From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Mon, 11 Jun 2007 10:00:53 +0200
Message-ID: <20070611080053.GD21969@kernel.dk>
References: <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:25946 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbXFKIC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 04:02:59 -0400
Content-Disposition: inline
In-Reply-To: <20070608153011.GA2375@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08 2007, Evgeniy Polyakov wrote:
> Size of the received file is bigger than file sent, file contains repeated
> blocks of data sometimes. Cloned skb usage is likely too big overhead,
> although for receiving fast clone is unused in most cases, so there
> might be some gain.

That was actually a new bug, here:

        plen -= *offset;
        poff += *offset;

in __skb_slice_bits(), we should only subtract the offset from plen, not
add to poff. Then we just create some weird hole without any meaning. So
remove those two poff additions in the two loops, and the size issue is
resolved at least.

-- 
Jens Axboe

