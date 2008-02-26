From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 13:30:30 -0800 (PST)
Message-ID: <20080226.133030.147637482.davem@davemloft.net>
References: <47C3B2D9.9090601@cn.fujitsu.com>
	<20080226073538.GA4101@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lyw@cn.fujitsu.com, swhiteho@redhat.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40183
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754772AbYBZV3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 16:29:46 -0500
In-Reply-To: <20080226073538.GA4101@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 26 Feb 2008 07:35:38 +0000

> On 26-02-2008 07:34, Li Yewang wrote:
> > Hi All
> > 
> >    There is a bug about icmp netunreach.
> >    If the kernel does not find a route for a packet, 
> >    it must send a icmp netunreach packet to the source host, 
> >    and  discard  the packet. But the  kernel  does not send 
> >    a icmp netunreach packet because of the  fib_lookup
> >    return value  of -ESRCH when a route  is not found. 
> 
> ...or because some function doesn't handle -ESRCH return from
> fib_lookup? It seems changing this to -ESRCH was needed in some cases.
> And you don't explain enough why it can't be handled later (like in
> ipv4/route.c: ip_route_input_slow)?

This was changed to -ESRCH so that the proper statistics
would be bumped.  So if we change it back, the statistics
will be broken again.
