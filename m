From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Sat, 21 Jun 2008 11:12:53 +0400
Message-ID: <20080621071253.GA17557@2ka.mipt.ru>
References: <20080618062857.GA3598@2ka.mipt.ru> <1213917029.9245.86.camel@localhost.localdomain> <20080620060219.GA22784@2ka.mipt.ru> <1213981859.9245.133.camel@localhost.localdomain> <20080620172513.GA16673@2ka.mipt.ru> <1213983664.9245.150.camel@localhost.localdomain> <20080620175440.GA12197@2ka.mipt.ru> <1213985826.9245.169.camel@localhost.localdomain> <20080620182333.GA9342@2ka.mipt.ru> <1213995972.9245.202.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35710 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbYFUHMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2008 03:12:51 -0400
Content-Disposition: inline
In-Reply-To: <1213995972.9245.202.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 04:06:12PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> This is what I have been focusing on. I'm still trying to figure out a
> good way to see if the interrupt is triggered for a specific packet
> because I have no way of determining which packet it will freeze on and
> if I put any prints in the interrupt handler or poll function it slows
> things down enough that the problem disappears.

It may or may not be the driver issue, but the way it works with NAPI.
Or driver just looses interrupt (or if it has weird interrupt
coalescing/mitigation feature) under the load. What about adding a
counter into interrupt handler and napi polling callback with ability to
clear/read it via driver ioctl (or just clear it when first small packet
is recived and dump when module is unloaded), so can determine via
tcpdump how many packets were actually received and what counter is.
It can be trivial issue with work_done < or <= than budget, which was a
frequent error in drivers for a while, and with your protocol it can be
fatal until next received packet.

-- 
	Evgeniy Polyakov
