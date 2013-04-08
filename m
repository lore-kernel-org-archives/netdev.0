From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 17:14:32 -0400 (EDT)
Message-ID: <20130408.171432.1360375865194610431.davem@davemloft.net>
References: <3294227.D2rod7xgQB@sifl>
	<1365454501.3887.45.camel@edumazet-glaptop>
	<6182509.cOVcY8B4g7@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mvadkert@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935988Ab3DHVOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 17:14:33 -0400
In-Reply-To: <6182509.cOVcY8B4g7@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 17:09:32 -0400

> On Monday, April 08, 2013 01:55:01 PM Eric Dumazet wrote:
>> At least my patch clearly _shows_ the security requirement, instead of
>> relying on a side effect of a previous sock_wmalloc()
> 
> I don't see it as a side effect, and as far as demonstration, I think the 
> SELinux network access controls in their entirety shows the security 
> requirement.  If we want to make the security requirements even more explicit 
> in the networking stack, let's add a security blob to the sk_buff and allow 
> some proper LSM hooks.

You don't get it.

Without LSM there is no need to use sock_wmalloc() or to have a socket
context attacked to the SYN/ACK packet at all.

Therefore, the need should be explicit (Eric's approach), rather than
implicit (what you seem to be after).
