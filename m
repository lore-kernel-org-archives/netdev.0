From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 09/13] clocksource: allow usage independent of
 timekeeping.c
Date: Wed, 12 Nov 2008 02:04:34 -0800 (PST)
Message-ID: <20081112.020434.50448090.davem@davemloft.net>
References: <1226414697.17450.852.camel@ecld0pohly>
	<1226415438.31699.8.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, dada1@cosmosbay.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751700AbYKLKEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:04:34 -0500
In-Reply-To: <1226415438.31699.8.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Tue, 4 Nov 2008 10:23:42 +0100

> So far struct clocksource acted as the interface between time/timekeeping
> and hardware. This patch generalizes the concept so that the same
> interface can also be used in other contexts.
> 
> The only change as far as kernel/time/timekeeping is concerned is that
> the hardware access can be done either with or without passing
> the clocksource pointer as context. This is necessary in those
> cases when there is more than one instance of the hardware.
> 
> The extensions in this patch add code which turns the raw cycle count
> provided by hardware into a continously increasing time value. This
> reuses fields also used by timekeeping.c. Because of slightly different
> semantic (__get_nsec_offset does not update cycle_last, clocksource_read_ns
> does that transparently) timekeeping.c was not modified to use the
> generalized code.
> 
> The new code does no locking of the clocksource. This is the responsibility
> of the caller.
> 
> Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>

This patch, since it changes generic facilities in the kernel rather
than networking specific ones, will need to get a full review on
linux-kernel
