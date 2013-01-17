From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Thu, 17 Jan 2013 17:54:54 -0500 (EST)
Message-ID: <20130117.175454.200184894667897570.davem@davemloft.net>
References: <1358450989-25205-1-git-send-email-sque@chromium.org>
	<87wqvbjujl.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sque@chromium.org, netdev@vger.kernel.org, msb@chromium.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab3AQWy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:54:56 -0500
In-Reply-To: <87wqvbjujl.fsf@dell.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Thu, 17 Jan 2013 23:47:58 +0100

>>>>>> "Simon" == Simon Que <sque@chromium.org> writes:
> 
>  Simon> In two places, tmp is initialized implicitly by being passed as a
>  Simon> pointer during a function call.  However, this is not obvious to the
>  Simon> compiler, which logs a warning.
> 
> What warning and what compiler version are you using?

I wouldn't bother asking this, unless it's so that you personally
can reproduce this in the future.

The compiler cannot determine with %100 certainty that tmp is
initialized in all paths.  Any time there are conditional
statements guarding setting and the use, the compiler is going
to err on the side of caution and say that if any of those
paths lead to a use without a set it's going to warn.

Even if it's actually impossible.
