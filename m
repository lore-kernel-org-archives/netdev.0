From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a
 cond_resched()
Date: Thu, 15 Nov 2007 00:57:20 -0800 (PST)
Message-ID: <20071115.005720.12599943.davem@davemloft.net>
References: <473B69D5.2050805@cosmosbay.com>
	<p73r6isc6ev.fsf@bingen.suse.de>
	<473C0297.5090004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751613AbXKOI5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 03:57:21 -0500
In-Reply-To: <473C0297.5090004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 15 Nov 2007 09:25:59 +0100

> Please note that :
> 
> if (need_resched())
>      cond_resched();
> 
> will re-test need_resched() once cond_resched() is called.
> 
> So it may sound unnecessary but in the rt_check_expire() case, with a loop 
> potentially doing XXX.XXX iterations, being able to bypass the function call 
> is a clear win (in my bench case, 25 ms instead of 88 ms). Impact on I-cache 
> is irrelevant here as this rt_check_expires() runs once every 60 sec.

BTW, Eric, initially I was going to recommend that you do
something like:

	if ((goal % SOME_POWER_OF_2) == 0)
		cond_resched();

to mitigate this cost but decided it wasn't worth the bother.
