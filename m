From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support
 implementation
Date: Wed, 23 Jan 2008 23:30:06 -0800 (PST)
Message-ID: <20080123.233006.124819204.davem@davemloft.net>
References: <p73odbclsft.fsf@crumb.suse.de>
	<78C9135A3D2ECE4B8162EBDCE82CAD7702E70E92@nekter>
	<20080124072549.GA6814@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna.Vepa@neterion.com, Sreenivasa.Honnur@neterion.com,
	netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60184
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752597AbYAXH35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 02:29:57 -0500
In-Reply-To: <20080124072549.GA6814@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 24 Jan 2008 08:25:49 +0100

> > have done away with handling tx completion in the interrupt handler, and
> > are instead handling them in the context of the transmit. The slow path,
> > straggling transmit completions will be handled in the timer context.
> 
> Ok -- hopefully you don't have bad corner cases from this when the pipe
> is not fully filled and then causing longer latencies on completion. 
> Old NAPI sometimes suffered from such problems. 

BTW, such a TX completion timer will stall TCP sockets when the TX
queue of the device is partially filled and then sending stops.

TX ring SKB liberation really must be done in a very small finite
amount of time in order to avoid this problem properly.

Deferring it to HZ granular timers doesn't give a quick enough
response, especially at high packet rates.
