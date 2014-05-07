From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP
 sockets
Date: Wed, 07 May 2014 01:38:20 -0400 (EDT)
Message-ID: <20140507.013820.1357850416047414291.davem@davemloft.net>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaEGFjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 01:39:06 -0400
In-Reply-To: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Tue,  6 May 2014 21:05:24 +0300

> Pardon the rough patch, but I hope it is enough to get some feedback
> on the overall approach.

Sorry I don't like this.

Walking a linked list unnecessary is going to add overhead to every
single packet transmission.  I think more people want our TCP stack to
be fast (everyone) than those who want option processing to be
abstracted enough to be modular (you).

Just make the intrusive changes, they are necessary as they force you
to think fully about how one option might interact with another.

I also disagree with the "if the option doesn't fit, send it in the
next packet" idea.  Where did that come from?

For SACK for example, that doesn't make any sense, and it's SACK
that usually can put us past the amount of space available.  For
SACK the thing to do is send the SACK information for the area
closest to what we've fully ACKd and just forget about advertising
the rest of the SACK blocks.
