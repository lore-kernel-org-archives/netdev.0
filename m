From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 05/10] headers, net: Define struct
 __kernel_sockaddr, replacing struct sockaddr
Date: Fri, 26 Aug 2011 11:08:20 -0400 (EDT)
Message-ID: <20110826.110820.2220935212459386472.davem@davemloft.net>
References: <1314247131.27179.116.camel@deadeye>
	<1314247456.27179.122.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab1HZPIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 11:08:31 -0400
In-Reply-To: <1314247456.27179.122.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 25 Aug 2011 05:44:15 +0100

> Commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305 ('net: Support
> inclusion of <linux/socket.h> before <sys/socket.h>') removed the
> definition of struct sockaddr for userland.
> 
> But we still have several headers using struct sockaddr, and we
> shouldn't make them include <sys/socket.h> as that risks recursive
> inclusion in future.  Define and use an identical struct
> __kernel_sockaddr instead.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
 ...
>  
> -/*
> - *	1003.1g requires sa_family_t and that sa_data is char.
> - */
> +#define sockaddr __kernel_sockaddr

This cure is worse than the disease.

Now any application that includes sys/socket.h one way or another is
now going to get a real hard build failure since __kernel_sockaddr
will effectively get redefined.

There is no reason sys/socket.h and our headers cannot co-exist and
this is the whole reason we're going through all of this pain to use
the __kernel_foo types in our networking datastructures which are
exposed to userspace.
