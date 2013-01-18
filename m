From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Fri, 18 Jan 2013 03:03:41 -0500 (EST)
Message-ID: <20130118.030341.2246222347501217868.davem@davemloft.net>
References: <87wqvbjujl.fsf@dell.be.48ers.dk>
	<20130117.175454.200184894667897570.davem@davemloft.net>
	<87sj5zj60q.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sque@chromium.org, netdev@vger.kernel.org, msb@chromium.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3ARIDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 03:03:45 -0500
In-Reply-To: <87sj5zj60q.fsf@dell.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Fri, 18 Jan 2013 08:37:41 +0100

>>>>>> "David" == David Miller <davem@davemloft.net> writes:
> 
>  >> What warning and what compiler version are you using?
> 
>  David> I wouldn't bother asking this, unless it's so that you personally
>  David> can reproduce this in the future.
> 
>  David> The compiler cannot determine with %100 certainty that tmp is
>  David> initialized in all paths.  Any time there are conditional
>  David> statements guarding setting and the use, the compiler is going
>  David> to err on the side of caution and say that if any of those
>  David> paths lead to a use without a set it's going to warn.
> 
> Sure, I just wondered as the code hasn't changed in 5+ years, and the
> function that gets called is defined just above, so the compiler should
> be able to figure it out.

Nothing guarentees that a piece of memory passed into an external
function has it's contents initialized completely by that function.

The compiler can't see what usbnet_read_cmd() does with the memory
behind the 'data' pointer argument.  So it makes the only assumption
it can make, which is that 'tmp' might be uninitialized.
