From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Mon, 21 Jul 2008 16:33:49 -0700 (PDT)
Message-ID: <20080721.163349.113841731.davem@davemloft.net>
References: <20080721115555.GA24176@elte.hu>
	<20080721192138.GA27672@elte.hu>
	<20080721212447.GA10107@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vegard.nossum@gmail.com, rjw@sisk.pl, cl@linux-foundation.org,
	auke-jan.h.kok@intel.com
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbYGUXdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 19:33:49 -0400
In-Reply-To: <20080721212447.GA10107@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 22 Jul 2008 01:24:48 +0400

> On Mon, Jul 21, 2008 at 09:21:38PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > So it's now a strong likelyhood that this crash is a combination of 
> > e1000e+netconsole.
> 
> e1000_clean_tx_irq() call looks particulary suspicious: it is called
> without adapter->tx_queue_lock in poll controller (netconsole callback)
> and with that lock in NAPI handler.
> 
> Can you check kind of this patch:

The call even seems pointless, since the caller will call
->poll() (which is e1000_clean) as the very next action,
and that will invoke e1000_clean_tx_irq() properly.

I would just delete this call from e1000_netpoll() entirely.
