From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: napi layer and packet throttling
Date: Fri, 24 May 2013 13:36:49 +0100
Message-ID: <1369399009.3469.273.camel@deadeye.wl.decadent.org.uk>
References: <519E030E.5040903@keymile.com>
	 <1369348056.6963.25.camel@bwh-desktop.uk.level5networks.com>
	 <519F1698.3050301@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Holger Brunck <holger.brunck@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50251 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab3EXMgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 08:36:53 -0400
In-Reply-To: <519F1698.3050301@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 09:28 +0200, Holger Brunck wrote:
> Hi Ben,
> 
> On 05/24/2013 12:27 AM, Ben Hutchings wrote:
> > On Thu, 2013-05-23 at 13:52 +0200, Holger Brunck wrote:
> >> b) Packet-Throttling
> >> Here the description says "NAPI-compliant drivers can often cause packets to be
> >> dropped in the network adaptor itself, before the kernel sees them at all."
> >>
> >> This is exactly what I need for my usecase. But I don't see any hints how this
> >> can be implemented with the napi layer.
> > [...]
> > 
> > If the RX ring is not cleaned and refilled quickly enough, the network
> > controller will naturally start to drop packets.  It's not something you
> > should do explicitly in the driver.
> > 
> 
> yes. But what if the remaining amount of packets which are getting through the
> napi_poll function into the linux system are still to many and generate
> therefore a to high softirq load on the system which leads to the problems I
> see.

Soft IRQs are then handled in a ksoftirqd thread, which is scheduled
like any other task (though it has high priority).

> Ok I could use a smaller amount of RX ring buffers, but then the system
> would get more intolerant for RX bursts what I don't want. I would like to
> protect the system if someone sends continuously a high packet rate to the
> interface, similar to DoS attacks.

This is not the job of the driver (beyond using NAPI in the first
place).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
