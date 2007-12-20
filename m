From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: neighbor timer power saving
Date: Thu, 20 Dec 2007 15:28:56 -0800 (PST)
Message-ID: <20071220.152856.39725559.davem@davemloft.net>
References: <20071218174120.4b0ef6dd@shemminger-laptop>
	<20071218181845.2f1b539a@shemminger-laptop>
	<4768C6FF.2090909@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, parag.warudkar@gmail.com,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54463
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbXLTX24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:28:56 -0500
In-Reply-To: <4768C6FF.2090909@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 19 Dec 2007 08:23:43 +0100

> We are going to convert 99% timers to deferrable.
> 
> Maybe the right move should be to have the reverse attribute, to
> mark a timer as non deferrable...

I think we are still in a learning process about what
exactly causes a timer to be converted to deferrable
or not.

It may sound crazy but flipping the switch on %99 of
our kernel timers is not the nicest way to figure it
out :-)

Therefore it might still make sense to keep the deferrable
marker for now, so that we can gradually convert the tree
checking easy case carefully.  This way the breakage is
containted very well.

Then once we have almost all of the timers verified, we
can reverse the meaning and mark the timers that remain
as non-deferrable and kill the deferrable marker.
