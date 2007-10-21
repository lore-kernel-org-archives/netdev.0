From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] niu: Cleanup PAGE_SIZE checks a bit
Date: Sun, 21 Oct 2007 16:35:58 -0700 (PDT)
Message-ID: <20071021.163558.98394216.davem@davemloft.net>
References: <20071020190649.GA30034@lixom.net>
	<20071020193357.GA2090@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48222
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbXJUXft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:35:49 -0400
In-Reply-To: <20071020193357.GA2090@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Sat, 20 Oct 2007 14:33:57 -0500

> PAGE_SIZE in this case is 64KB, so I don't quite get why gcc can't tell
> that the line in question will never be reached.

GCC does not do that kind of full flow analysis based upon constant
expression simplification to determine if a store like this into a
type smaller than the constant value can handle can actually occur.

> I suggest the following instead, but I can unfortunately not do anything but
> build test it.
> 
> Also, the driver does some other checks to make sure that PAGE_SIZE is a
> power of two (BUILD_BUG_ON() in niu_init()), doesn't seem like that could
> ever be untrue? Or are there really archs with non-power-of-two PAGE_SIZE?

It was just overly-anal assertion checking.  I tend to prefer using
code instead of comments to describe invariants, but this one is
pretty unrealistic and silly.

> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> --
> 
> Ack! It should obviously use min(), not max()!

:-)

Applied, thanks!
