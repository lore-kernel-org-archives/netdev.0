From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:37:30 -0800
Message-ID: <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36772 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcA2Thd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:37:33 -0500
Received: by mail-pf0-f177.google.com with SMTP id n128so46551353pfn.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 11:37:32 -0800 (PST)
In-Reply-To: <20160129.110634.1678121731419241040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 11:06 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jan 2016 10:33:48 -0800
> 
> > Why ipv6 stack itself does not trigger the issue ?
> > 
> > Maybe the driver itself does not properly align IP headers on sparc ?
> > 
> > Make sure NET_IP_ALIGN is 2 on your build.
> > 
> > Note that x86 does not care, but a driver should always align Ethernet
> > header to NET_IP_ALIGN, so that IP headers are aligned to 4 bytes
> > boundaries.
> 
> Eric, please reread the original posting, the driver is trying to do
> exactly this.

Sure, but this driver was tested on x86.

> 
> This is the part in the driver where it is trying to figure out how
> much to pull in order to align the packet before it gets sent into the
> stack.
> 
> That's why only the flow dissector sees this problem.

I have no idea why reading iph->saddr or iph->daddr would not hit the
problem, but accessing the 32bit ipv6 flow label would be an issue.

Something is fishy.

But really adding unaligned() accesses in flow dissector would slow it
quite a lot on MIPS and others.
