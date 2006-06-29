From: "Chris Friesen" <cfriesen@nortel.com>
Subject: jumbo frames and memory fragmentation
Date: Thu, 29 Jun 2006 12:54:15 -0600
Message-ID: <44A421D7.2030609@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:38544 "EHLO
	zrtps0kn.nortel.com") by vger.kernel.org with ESMTP
	id S1751267AbWF2SyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 14:54:23 -0400
Received: from zcarhxs1.corp.nortel.com (zcarhxs1.corp.nort...s0.corp.nortel.com [47.129.230.89])
	by zrtps0kn.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id k5TIsK813805
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:54:20 -0400 (EDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm running a system with multiple e1000 devices, using 9KB jumbo 
frames.  I'm running a modified 2.6.10 with e1000 driver 5.5.4-k2.

I'm a bit concerned about the behaviour of this driver with jumbo 
frames.  We ask for 9KB.  The driver then bumps that up to a 
power-of-two, so it calls dev_alloc_skb(16384).  That then bumps it up a 
bit to allow for its own overhead, so it appears that we end up asking 
for 32KB of physically contiguous memory for every packet coming in.  Ouch.

Add to that the fact that this version of the driver doesn't do 
copybreak, and it means that after we're up for a few days it starts 
complaining about not being able to allocate buffers.

Anyone have any suggestions on how to improve this?  Upgrading kernels 
isn't an option.  I could port back the copybreak stuff fairly easily.

Back in 2.4 some of the drivers used to retry buffer allocations using 
GFP_KERNEL once interrupts were reenabled.  I don't see many of them 
doing that anymore--would there be any benefit to that?

Thanks,

Chris
