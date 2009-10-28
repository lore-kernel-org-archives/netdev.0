From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] fib_hash: improve route deletion scaling on
 interface drop with lots of interfaces
Date: Tue, 27 Oct 2009 18:01:04 -0700 (PDT)
Message-ID: <20091027.180104.135164582.davem@davemloft.net>
References: <20091027000302.GA3141@kvack.org>
	<20091026.171749.106971240.davem@davemloft.net>
	<20091027142426.GB3141@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@lhnet.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757078AbZJ1BAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:00:40 -0400
In-Reply-To: <20091027142426.GB3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@lhnet.ca>
Date: Tue, 27 Oct 2009 10:24:26 -0400

> On Mon, Oct 26, 2009 at 05:17:49PM -0700, David Miller wrote:
>> > bottleneck.  Next up in the network code is rt_cache_flush().  Comments?
>> 
>> On a real router adding and removing routes is happening a lot
>> whereas interface changes are rare.  You're making a more common
>> operation more expensive for the sake of a less common one.
> 
> It's not a question of more common vs less common, but if the system can 
> recover from an adverse event within a reasonable amount of time.  Tunnel 
> flaps occur in the real world, and this results in the change of state of 
> a large number of interfaces at the same time.  Would it be okay if this 
> is wrapped in a config option?  I agree that the extra overhead is not 
> for everyone.

Having it in a config option is worse, distributions are going
to turn it on so it would be protecting nothing for %99.999 of
folks out there.
