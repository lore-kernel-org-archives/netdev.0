From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 16:46:46 -0700 (PDT)
Message-ID: <20101025.164646.104054845.davem@davemloft.net>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
	<1288045856.3296.19.camel@edumazet-laptop>
	<20101025233558.GA30118@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jpirko@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752873Ab0JYXqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 19:46:23 -0400
In-Reply-To: <20101025233558.GA30118@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 25 Oct 2010 19:35:58 -0400

> On Tue, Oct 26, 2010 at 12:30:56AM +0200, Eric Dumazet wrote:
>> I would try a two level thing : Try to get high order pages, and
>> fallback on low order pages, but normally libpcap does this for us ?
>> 
>> 
> It does, but it tries them in that order, which causes the problem I'm
> describing, which is to say that attempting to get a large high order allocation
> causes the system to dig into swap and become unresponsive while it tries to
> assemble those allocations.  I would suggest a vmalloc, with a backoff to high
> order allocation if that fails.

I think that logic should be maintained, except that one of the GFP_*
flags should be specified so that it doesn't go all swap crazy on us,
and instead fails a high order allocation earlier.
