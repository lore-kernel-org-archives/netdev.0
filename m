From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 07 Mar 2011 13:50:59 -0800 (PST)
Message-ID: <20110307.135059.229761671.davem@davemloft.net>
References: <20110307.134001.245386278.davem@davemloft.net>
	<20110307214812.GA19540@mtldesk30>
	<20110307.134931.232736253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@purestorage.com, netdev@vger.kernel.org
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754696Ab1CGVuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:50:22 -0500
In-Reply-To: <20110307.134931.232736253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 07 Mar 2011 13:49:31 -0800 (PST)

> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Mon, 7 Mar 2011 23:48:12 +0200
> 
>> On Mon, Mar 07, 2011 at 01:40:01PM -0800, David Miller wrote:
>>> From: Eli Cohen <eli@dev.mellanox.co.il>
>>> Date: Mon, 7 Mar 2011 23:36:48 +0200
>>> 
>>> > Specifically, some archs may not support write combining.
>>> 
>>> They should just create a non-write-combining mapping if they
>>> don't support it.
>>> 
>> 
>> I wouldn't expect that since the caller function could be mislead to
>> believe it has a write combining capable area.
> 
> It's a performance optimization, if you don't get write combining you'll
> get more strict ordering, rather than less.
> 
> It cannot cause problem.

BTW, if we did as you suggest, fail if we don't support write combining,
then half the drivers in the tree would fail to probe on sparc64.

Every other driver expects it to succeed, with either write-combining
or more strict ordering semantics.  Never to fail simply because
write-combining isn't supported.

It's a request, not a requirement.

