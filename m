From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 05/10] headers, net: Define struct
 __kernel_sockaddr, replacing struct sockaddr
Date: Fri, 26 Aug 2011 16:42:48 +0100
Message-ID: <20110826154248.GD24107@decadent.org.uk>
References: <1314247131.27179.116.camel@deadeye>
 <1314247456.27179.122.camel@deadeye>
 <20110826.110820.2220935212459386472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60187 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754497Ab1HZPmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 11:42:51 -0400
Content-Disposition: inline
In-Reply-To: <20110826.110820.2220935212459386472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2011 at 11:08:20AM -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Thu, 25 Aug 2011 05:44:15 +0100
> 
> > Commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305 ('net: Support
> > inclusion of <linux/socket.h> before <sys/socket.h>') removed the
> > definition of struct sockaddr for userland.
> > 
> > But we still have several headers using struct sockaddr, and we
> > shouldn't make them include <sys/socket.h> as that risks recursive
> > inclusion in future.  Define and use an identical struct
> > __kernel_sockaddr instead.
> > 
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>  ...
> >  
> > -/*
> > - *	1003.1g requires sa_family_t and that sa_data is char.
> > - */
> > +#define sockaddr __kernel_sockaddr
> 
> This cure is worse than the disease.
> 
> Now any application that includes sys/socket.h one way or another is
> now going to get a real hard build failure since __kernel_sockaddr
> will effectively get redefined.
[...]
 
This #define is in the #ifdef __KERNEL__ section.  I don't want t
change all the in-kernel users to say __kernel_sockaddr.  This is
just the same as the preceding 'typedef __kernel_sa_family_t
sa_family_t' except that you can't create struct aliases that way.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
