From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Mon, 03 May 2010 14:13:53 -0700 (PDT)
Message-ID: <20100503.141353.32722085.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D6DE63A@MORGANITE.micrel.com>
	<20100503.130316.56362236.davem@davemloft.net>
	<14385191E87B904DBD836449AA30269D6DE671@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org, support@tincantools.com
To: Tristram.Ha@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756786Ab0ECVNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 17:13:47 -0400
In-Reply-To: <14385191E87B904DBD836449AA30269D6DE671@MORGANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Mon, 3 May 2010 14:11:41 -0700

> I thought the transmit check workqueue reschedules itself when the
> buffer available is still not enough, and this is the part you objected.

If it reschedules itself, it runs immediately.  That will just hog a cpu
endlessly until the TX packets start to be transmitted by the chip.  That's
just as bad a polling in a loop.

You need to use an hrtimer or similar.
