From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 15:18:24 -0700 (PDT)
Message-ID: <20080827.151824.14173512.davem@davemloft.net>
References: <87vdxmr53f.fsf@basil.nowhere.org>
	<48B57BD3.5050206@hp.com>
	<20080827162735.GW26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, johnpol@2ka.mipt.ru, dada1@cosmosbay.com,
	denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47893
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753199AbYH0WS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:18:28 -0400
In-Reply-To: <20080827162735.GW26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 27 Aug 2008 18:27:35 +0200

> > Those banks really want to crank down on latency - to the point they 
> > start disabling interrupt coalescing.  I bet they'd toss anything out 
> > they could to shave another microsecond.
> 
> This change would actually likely lower their latency.

They want the timestamps, but they want it to match when the packet
arrived at their system as closely as is reasonably possible.

Socket based solutions don't do that, because we can be sleeping on
GFP_KERNEL memory or similar with the socket locked, and thus not
be able to set the timestamp until the task wakes up and processes
the backlog.
