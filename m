From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 08:57:37 -0800
Message-ID: <1358096257.8744.112.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
	 <1358046374.20249.1789.camel@edumazet-glaptop>
	 <20130113035013.GJ5259@kvack.org>
	 <1358056199.20249.2121.camel@edumazet-glaptop>
	 <50F2C860.1060602@mojatatu.com>  <20130113164141.GL5259@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38737 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992Ab3AMQ5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 11:57:40 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so1809422pad.25
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 08:57:40 -0800 (PST)
In-Reply-To: <20130113164141.GL5259@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-13 at 11:41 -0500, Benjamin LaHaise wrote:
> Hi folks,
> 
> On Sun, Jan 13, 2013 at 09:44:48AM -0500, Jamal Hadi Salim wrote:
> > Eric, the point probably Ben was trying to make is not about 
> > synchronizing rather about which namespace has the right to that action 
> > config. Your change is correct for the common use of actions
> > but does not fix the larger picture.
> ...
> > In such a case, the "tc actions" netlink path may be
> > entered from a different namespace than the one that is
> > using it. Then current->nsproxy->net_ns is no longer correct.
> > 
> > To correct this, i think what Ben points out in passing the
> > init() the correct namespace seem like the way to go. Feel free
> > to make that change - otherwise i will get to it and fix it.
> 
> Yep, Jamal's right on the point I'm trying to make.  To deal with this, I 
> think we need a patch along the lines of the following to pass the 'struct 
> net *' down to where it's needed...  Please note that I've only compile 
> tested this with all the net/sched modules enabled and a allmodconfig 
> build.  It's a bit bigger, but passing the argument down through the call 
> chain looks simpler than trying to stuff a struct net pointer into the 
> various structures and keep that in sync with the network device's network 
> namespace.
> 
> 		-ben
> -- 
> "Thought is the essence of where you are now."
> 
> -- 
> pkt_sched: namespace aware ifb v2
> 
> Eric Dumazet pointed out that act_mirred needs to find the current net_ns,
> and struct net pointer is not provided in the call chain.  His original
> patch made use of current->nsproxy->net_ns to find the network namespace,
> but this fails to work correctly for userspace code that makes use of
> netlink sockets in different network namespaces.  Instead, pass the
> "struct net *" down along the call chain to where it is needed.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> ---

OK I'll test it at the end of the (sunny) day.

Thanks
