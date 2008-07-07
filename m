From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Mon, 07 Jul 2008 16:56:38 -0500
Message-ID: <1215467798.14023.130.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
	 <1213743506.5771.220.camel@localhost.localdomain>
	 <48584CAD.6010509@candelatech.com>
	 <1213915992.9245.71.camel@localhost.localdomain>
	 <485E185E.1090807@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:42839 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757324AbYGGV5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:57:31 -0400
In-Reply-To: <485E185E.1090807@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-06-22 at 10:16 +0100, James Chapman wrote:
> 
> I looked at macb.c and can see that it uses napi only for rx work, 
> leaving tx interrupts enabled at all times. The interrupt handler reads 
> the device interrupt status when a tx interrupt happens and may find rx 
> bits also set. As a result, your netif_rx_schedule_prep() will sometimes 
> return false because napi might be already scheduled. The code you have 
> above (i.e. the "driver bug" case) is wrong.

Thanks for the reply James.

That is somewhat confusing to me because once an rx interrupt is
detected and the rx interrupts are disabled the rx bits should not be
set in the interrupt status register until they are re-enabled again
after polling has finished. Can you explain your point a little more?

>From what I can tell, an interrupt would need to come in between when
the ISR is read and when the rx bits are tested and rx ints are disabled
for it to be there the next time around in the while(status) loop.
Looking at it that way, it is completely possible.

> The napi code in the in-tree version looks suspect because it seems to 
> enable rx interrupts unconditionally regardless of whether napi rx 
> processing is complete.

Correct, this is one of the reasons that I rewrote the driver poll
function. There are a couple of other issues that I noticed as well.

> It might help to post a patch here showing all of your changes.

Did this earlier today, I should get a patch against 2.6.25 up tomorrow
which will be a little more useful.

Thanks!

Travis

