From: David Miller <davem@davemloft.net>
Subject: Re: ssb: Fix DMA-API compilation for non-PCI systems
Date: Mon, 10 Nov 2008 13:52:31 -0800 (PST)
Message-ID: <20081110.135231.96349017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751243AbYKJVwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:52:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I applied this since it's a build buster and we should
get it fixed quickly.

But as I look at this, the thing to really do here is get
rid of these stupid switch statements.  None of it is needed.

The layer that sets up the SSB devices should simply save the
generic device pointer for the DMA entity into some new
->dma_dev struct member.

Then you just use generic dma_*() interfaces unilaterally.  For PCI
devices it will "just work".
