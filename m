From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Fri, 25 Feb 2011 23:09:39 -0800 (PST)
Message-ID: <20110225.230939.112589117.davem@davemloft.net>
References: <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	<20100901.183251.106803238.davem@davemloft.net>
	<1298312395.2608.65.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751444Ab1BZHJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 02:09:04 -0500
In-Reply-To: <1298312395.2608.65.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 21 Feb 2011 18:19:55 +0000

> On Wed, 2010-09-01 at 18:32 -0700, David Miller wrote:
>> 2) TX queue datastructures in the driver get reallocated using
>>    memory in that NUMA domain.
> 
> I've previously sent patches to add an ethtool API for NUMA control,
> which include the option to allocate on the same node where IRQs are
> handled.  However, there is currently no function to allocate
> DMA-coherent memory on a specified NUMA node (rather than the device's
> node).  This is likely to be beneficial for event rings and might be
> good for descriptor rings for some devices.  (The implementation I sent
> for sfc mistakenly switched it to allocating non-coherent memory, for
> which it *is* possible to specify the node.)

The thing to do is to work with someone like FUJITA Tomonori on this.

It's simply a matter of making new APIs that take the node specifier,
have the implementations either make use of or completely ignore the node,
and have the existing APIs pass in "-1" for the node or whatever the
CPP macro is for this :-)
