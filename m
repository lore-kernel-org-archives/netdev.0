From: David Miller <davem@davemloft.net>
Subject: Re: netlink_proto_init and sock_init
Date: Thu, 27 Dec 2007 16:41:28 -0800 (PST)
Message-ID: <20071227.164128.142446759.davem@davemloft.net>
References: <200712271448.57008.tavi@cs.pub.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tavi@cs.pub.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753692AbXL1Al2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 19:41:28 -0500
In-Reply-To: <200712271448.57008.tavi@cs.pub.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <tavi@cs.pub.ro>
Date: Thu, 27 Dec 2007 14:48:56 +0200

> I've noticed that with some exotic build setups (e.g. mingw) 
> netlink_proto_init is called before sock_init and subsequently sock_alloc 
> runs into a NULL sock_mnt. The following patch seems to fix the problem, but 
> I'm not sure if this is the right thing to do, as there are no _initcall_sync 
> calls in the kernel yet. 

This means that net/netlink/ got linked before net/socket.o, which
should never happen.  net/Makefile reads:

obj-$(CONFIG_NET)		:= socket.o core/
 ...
obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/

Which ensures that net/socket.o comes before linking in the
net/netlink/built-in.o object file.

Init call ordering is based upon link ordering, so it looks like
mingw is somehow reordering the object files being linked.

There are many other things that can go wrong if the build environment
does this, please find a way to get your mingw build environment to
not do this.
