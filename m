From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Thu, 26 Jul 2007 00:15:16 -0700 (PDT)
Message-ID: <20070726.001516.48528000.davem@davemloft.net>
References: <20070725.233808.41635535.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AAB9F8@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757033AbXGZHPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:15:17 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AAB9F8@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 26 Jul 2007 00:05:47 -0700

> David Miller wrote:
> 
> > So that ->poll_controller() can process TX acks by just having
> > the TX lock and interrupts disabled.
> > 
> > Can you think of another way to process TX acks from absolutely
> > any execution context whatsoever?  That's what we need and
> > preferably in some generic way, and the above is what I came
> > up with.
> 
> What are we trying to protect against by taking the TX lock before
> calling ->poll_controller()?

The netpoll code has to take that anyways in order to call
into ->hard_start_xmit() to send out the packet it has
pending, I'm leveraging that as a synchronization mechanism
in the drivers because the locking options are limited
given that netpoll can try to do this in any context whatsoever.

> There is a measurable difference in oprofile.  When passing small
> packets, there's a non-trivial difference in throughput.

Then please help come up with an alternate scheme, because these
NAPI changes fix real limitations and bugs in the current code
and unless we fix netpoll too we can't move forward.

Thanks.
