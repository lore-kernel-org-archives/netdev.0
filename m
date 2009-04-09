From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 09 Apr 2009 14:17:40 -0700 (PDT)
Message-ID: <20090409.141740.78414724.davem@davemloft.net>
References: <20090408160948.2257d311@s6510>
	<20090408.161515.40986410.davem@davemloft.net>
	<65634d660904090943lf273d9cg92be105acef3e6af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752962AbZDIVRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 17:17:50 -0400
In-Reply-To: <65634d660904090943lf273d9cg92be105acef3e6af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 9 Apr 2009 09:43:07 -0700

> The bimodal behavior between polling and non-polling states does give
> us fits.  I looked at the parked mode idea, but the latency hit seems
> too high.  We've considered holding the interface in polling state for
> longer periods of time, maybe this could trade off CPU cycles (on the
> core taking interrupts) for lower latency and higher throughput.

The sweet spot is usually obtained by having moderate HW interrupt
mitigation settings.  Unfortunately not all drivers do this
universally and have been well tuned.  tg3 is one driver that does do
this correctly.

I would imagine that a non-trivial swath of the issues you guys run
into are actually driver related.  It took us a while to get the tg3
HW interrupt mitigations to play just-right with NAPI.

And we were able to get it right because on a particular system the
NAPI transition was incredibly expensive (some big NUMA SGI box)
so all of the effects were pronounced.
