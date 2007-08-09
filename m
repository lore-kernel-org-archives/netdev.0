From: David Miller <davem@davemloft.net>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Wed, 08 Aug 2007 21:40:54 -0700 (PDT)
Message-ID: <20070808.214054.133430158.davem@davemloft.net>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
	<20070807.182823.123919803.davem@davemloft.net>
	<46B9DF25.3000800@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751786AbXHIEky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 00:40:54 -0400
In-Reply-To: <46B9DF25.3000800@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Wed, 08 Aug 2007 11:20:05 -0400

> I believe the current calculation is correct.  The RFC specifies a 
> window of no more than 4380 bytes unless 2*MSS > 4380.  If you change 
> the code in this way, then MSS=1461 will give you an initial window of 
> 3*MSS == 4383, violating the spec.  Reading the pseudocode in the RFC 
> 3390 is a bit misleading because they use a clamp at 4380 bytes rather 
> than use a multiplier in the relevant range.

Thanks for this excellent clarification John.

Because this has tripped up enough people, not once but on
multiple occaisions, I'm going to add some comments to
tcp_init_cwnd() to save the next person who is confused
by what seems to be an incorrect implementation of the RFC :-)
