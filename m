From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Wed, 28 May 2008 22:34:15 -0700 (PDT)
Message-ID: <20080528.223415.193732490.davem@davemloft.net>
References: <20080526.151540.191673092.davem@davemloft.net>
	<483BA80C.4020502@krogh.cc>
	<483CB301.40007@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59392
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750863AbYE2FeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 01:34:19 -0400
In-Reply-To: <483CB301.40007@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Tue, 27 May 2008 18:18:57 -0700

> Considering that fixing the HW would take considerable time, I was 
> wondering if the scheme we use in the nxge driver could be considered as 
> a workaround. Since the niu driver is already doing skb_orphan as a work 
> around, what if  already transmitted TX buffers are  reclaimed 
> periodically, within dev->hard_start_xmit() ?  Then TX_DESC_MARK would 
> be set if/when available TX descriptor count falls below some watermark. 
> Disable device TX queue about the time  TX_DESC_MARK is set and enable 
> it within TX interrupt.

Since my hack patch didn't fix his problem at all, are you suggesting
that we end up not fielding TX mark interrupts even though mark is set
in all the TX descriptors and this is what hangs the chip?

I find that very unlikely, especially because with my test patch every
single TX descriptor will have the mark bit set and therefore we'd
have to not receive all of those TX mark interrupts in order for the
TX unit to hang like that.

Something else must be going wrong.
