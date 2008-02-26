From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 23:44:38 +0100
Message-ID: <20080226224438.GA19937@ami.dom.local>
References: <47C3B2D9.9090601@cn.fujitsu.com> <20080226073538.GA4101@ff.dom.local> <20080226.133030.147637482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lyw@cn.fujitsu.com, swhiteho@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:61338 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758868AbYBZWld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 17:41:33 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1262806nfb.21
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 14:41:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080226.133030.147637482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 01:30:30PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 26 Feb 2008 07:35:38 +0000
> 
> > On 26-02-2008 07:34, Li Yewang wrote:
> > > Hi All
> > > 
> > >    There is a bug about icmp netunreach.
> > >    If the kernel does not find a route for a packet, 
> > >    it must send a icmp netunreach packet to the source host, 
> > >    and  discard  the packet. But the  kernel  does not send 
> > >    a icmp netunreach packet because of the  fib_lookup
> > >    return value  of -ESRCH when a route  is not found. 
> > 
> > ...or because some function doesn't handle -ESRCH return from
> > fib_lookup? It seems changing this to -ESRCH was needed in some cases.
> > And you don't explain enough why it can't be handled later (like in
> > ipv4/route.c: ip_route_input_slow)?
> 
> This was changed to -ESRCH so that the proper statistics
> would be bumped.  So if we change it back, the statistics
> will be broken again.

Actually, I liked more this sophisticated explanation from the changelog:

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=83886b6b636173b206f475929e58fac75c6f2446

BTW, it's really hard to find any place which could still behave as
described by Li. Wasn't it with some older kernel?

Jarek P.
