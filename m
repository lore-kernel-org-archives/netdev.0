From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 09:59:29 -0500
Message-ID: <20130113145929.GK5259@kvack.org>
References: <50F1699E.1000200@hartkopp.net> <20130112.132316.2121287993605534669.davem@davemloft.net> <20130112.133630.257139657732337147.davem@davemloft.net> <1358046374.20249.1789.camel@edumazet-glaptop> <20130113035013.GJ5259@kvack.org> <1358056199.20249.2121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:47753 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755061Ab3AMO7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 09:59:30 -0500
Content-Disposition: inline
In-Reply-To: <1358056199.20249.2121.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 12, 2013 at 09:49:59PM -0800, Eric Dumazet wrote:
> But it is working in my tests.
> 
> I added a WARN and the call stack is :
...
> Could you elaborate on what could be the problem ?
> 
> We hold the RTNL, so I dont think another process could possibly call
> tcf_mirred_init()

The locking isn't the issue, but how the network namespace is selected it.  
I've implemented some virtual router functionality using network namespaces, 
and prior to having the setns() syscall, the only way to manipulate other 
network namespaces was via socket passing between threads in different 
namespaces.  One of the optimizations in using this technique was to open a 
netlink socket in another namespace, then pass that file descriptor back to 
the main daemon.  The code could then add routes and manipulate other areas 
of the network stack via that netlink socket.

I think this technique is a valid approach for making use of network 
namespaces.  It also has the benefit of avoid the use of setns() for the 
vast majority of operations.

		-ben
-- 
"Thought is the essence of where you are now."
