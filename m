From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 12:27:57 -0700 (PDT)
Message-ID: <20101027.122757.98903207.davem@davemloft.net>
References: <20101027.105047.183059900.davem@davemloft.net>
	<1288203979.1836.2.camel@dan>
	<AANLkTikKZdq9u0+Nkd4wtEcAZMT3YCPaXMv6FZaafetc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753284Ab0J0T1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:27:34 -0400
In-Reply-To: <AANLkTikKZdq9u0+Nkd4wtEcAZMT3YCPaXMv6FZaafetc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Oct 2010 11:51:19 -0700

> So doing this in verify_iovec() (and verify_compat_iovec - which I
> didn't do in my RFC patch) really does fix everything, and means that
> the individual socket types never have to worry about the subtle cases
> of overflow in any type.

I completely agree about capping things in verify_iovec().

And it was completely erroneous of me to change verify_iovec() to
return 'long' instead of 'int', it should have stayed at 'int' with a
cap.

Because the protocols don't even have a way to return something larger
than an 'int' as a return value due to the signature of the recvmsg()
and sendmsg() socket ops.
