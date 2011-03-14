From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 14:41:56 -0700 (PDT)
Message-ID: <20110314.144156.245399355.davem@davemloft.net>
References: <1300137299-28161-1-git-send-email-msmith@cbnco.com>
	<20110314.142520.28811818.davem@davemloft.net>
	<4D7E88C7.5080706@cbnco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msmith@cbnco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54169
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab1CNVlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:41:19 -0400
In-Reply-To: <4D7E88C7.5080706@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Smith <msmith@cbnco.com>
Date: Mon, 14 Mar 2011 17:29:43 -0400

> David Miller wrote:
>> Secondly, fib_validate_source() already takes too many damn arguments.
>> Find another, less costly, way to pass this information down there.
> 
> What would be a less costly way to pass it? Could I just hand it the
> whole skb?

I don't see how passing a pointer is better than passing an interger.
In both cases you're adding an extra argument to the function.

I was trying to get you to think out of the box and come up with
something clever, but that isn't working. :-)

>> Frankly, I think RPF should be disabled completely by default.  When
>> it doesn't do anything useful, it's making route lookups twice as
>> expensive as they need to be.
> 
> Yeah, it's disabled by default. It's an easy way of preventing
> spoofing of internal source addresses from the Internet, so I like it.

It is not "disabled by default".  fib_validate_source() still does a
limited validation of the reverse path, even with the sysctl is set to
zero.

I want it to do absolutely nothing, and instead just use inet_select_addr()
to calculate spec_dst.

Even the spec_dst calculation is spurious, necessary only in limited
situations, and even in that case only takes on special values for
multicast and broadcast addresses.

In short, fib_validate_source() is nothing but completely unnecessary
overhead in the common case.
