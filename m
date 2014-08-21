From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lec: Use rtnl lock/unlock when updating MTU
Date: Thu, 21 Aug 2014 16:31:53 -0700 (PDT)
Message-ID: <20140821.163153.979300888539356946.davem@davemloft.net>
References: <20140814.143706.1833450188258591738.davem@redhat.com>
	<201408150056.s7F0uRg7003712@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792AbaHUXby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:31:54 -0400
In-Reply-To: <201408150056.s7F0uRg7003712@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Thu, 14 Aug 2014 20:56:27 -0400

> In message <20140814.143706.1833450188258591738.davem@redhat.com>,David Miller writes:
>>From: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
>>Date: Thu, 14 Aug 2014 09:19:47 -0400
>>
>>> The LECS response contains the MTU that should be used.  Correctly
>>> synchronize with other layers when updating.
>>> 
>>> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
>>
>>I don't think you can sleep from this function, which rtnl_lock() may
>>require.  Look elsewhere in this routine, it's doing GFP_ATOMIC
>>allocations even.
> 
> Its been a while but...
> 
> This is the send routine for a virtual atm device that is the control
> interface bewteen the user space client and the kernel.  The user space
> client creates an atm socket and uses an ioctl to connect that atm socket
> to the this virtual device.  So the call path is something like:
> 
> sendmsg() -> vcc_sendmsg() -> virtual atm device.send()
> 
> Generally speaking, you can't sleep in the send routine of an atm device
> since there are other potential users besides sockets.
> 
> The GFP_ATOMIC usage is probably a lack of understanding.  The other
> IRQ level locks are necessary for coordination.

Ok, that makes sense, thanks for explaining the context in which this is
invoked.

Patch applied, thanks again.
