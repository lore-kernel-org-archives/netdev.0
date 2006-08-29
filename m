From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH IPv6] Fix race condition in ipv6_add_addr
Date: Tue, 29 Aug 2006 02:45:46 -0700 (PDT)
Message-ID: <20060829.024546.105431617.davem@davemloft.net>
References: <20060829083536.GA10403@suse.de>
	<20060829.182128.23425629.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@vger.kernel.org, keir.fraser@cl.cam.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60375
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964833AbWH2JqH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:46:07 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060829.182128.23425629.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 29 Aug 2006 18:21:28 +0900 (JST)

> In article <20060829083536.GA10403@suse.de> (at Tue, 29 Aug 2006 10:35:36 +0200), Olaf Kirch <okir@suse.de> says:
> 
> > During stress testing, machines were frequently crashing in
> > __ipv6_ifa_notify on dst_hold(&ifp->rt.u_dst), with ifp->rt being a
> > NULL pointer.
> > 
> > The attached patch fixes the problem.
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks everyone.

Although the only reason this is a problem is due to the fact that we
use rwlock's here.  If addrconf_lock were a normal spinlock, or taken
as a writer in this code path, the problematic cases would not be
possible.

I guess this is a reminder that I need to revisit my patches which
move all IPV6 address and inet6_dev changes out of software interrupt
context, plus add use of RCU. :-)
