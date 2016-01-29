From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 14:44:34 -0500
Message-ID: <20160129194434.GC17127@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160129.110634.1678121731419241040.davem@davemloft.net>
 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23213 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689AbcA2Ton (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:44:43 -0500
Content-Disposition: inline
In-Reply-To: <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 11:37), Eric Dumazet wrote:
> 
> I have no idea why reading iph->saddr or iph->daddr would not hit the
> problem, but accessing the 32bit ipv6 flow label would be an issue.
> 
> Something is fishy.

I was wondering about this myself. Even on sparc, I only first
ran into the errors for ipv6. I dont know if the fact that the
saddr is memcpy'ed masks the error (even though the problem
is still there). 

But doing the check of: if (!IS_ALIGNED(..)) on the iph->saddr in the
code does result in a positive.

> But really adding unaligned() accesses in flow dissector would slow it
> quite a lot on MIPS and others.
