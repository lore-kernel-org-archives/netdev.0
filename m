From: David Miller <davem@davemloft.net>
Subject: Re: Regression caused by commit "netfilter: iptables: lock free
 counters"
Date: Sun, 05 Apr 2009 01:22:37 -0700 (PDT)
Message-ID: <20090405.012237.198610462.davem@davemloft.net>
References: <20090329234702.4988017f@desktop.r000n.info>
	<8763hja8cy.fsf@newton.gmurray.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: graham@gmurray.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758619AbZDEIWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 04:22:49 -0400
In-Reply-To: <8763hja8cy.fsf@newton.gmurray.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graham Murray <graham@gmurray.org.uk>
Date: Sun, 05 Apr 2009 08:05:17 +0100

Please CC the appropriate mailing lists (as I have now) when reporting
this incredibly useful information.  The networking and netfilter
developers largely do not read linux-kernel.

> Roman Mindalev <r000n@r000n.net> writes:
> 
> > Result of the bisection:
> >
> > 784544739a25c30637397ace5489eeb6e15d7d49 is first bad commit
> > commit 784544739a25c30637397ace5489eeb6e15d7d49             
> 
> I am seeing a different problem which also bisects to this commit. There are
> no kernel messages but ip6tables fails to run.
> 
> newton ~ # ip6tables -L -v
> FATAL: Module ip6_tables not found.
> ip6tables v1.4.3.1: can't initialize ip6tables table `filter': Memory allocation problem
> Perhaps ip6tables or your kernel needs to be upgraded.
> 
> I get this error no matter which ip6tables sub-command I run. Ip6tables
> is built into the kernel, not as modules.
> 
> An strace shows the failure to be 
> socket(PF_INET6, SOCK_RAW, IPPROTO_RAW) = 3
> getsockopt(3, SOL_IPV6, 0x40 /* IPV6_??? */, "filter\0\305\0w~\300\0wb\305P\24\312\t\0009b\305\216\23\0\0\310\341/g\16"..., [84]) = 0
> brk(0)                                  = 0x8273000
> brk(0x8294000)                          = 0x8294000
> getsockopt(3, SOL_IPV6, 0x41 /* IPV6_??? */, 0x8273090, 0xbfd23628) = -1 ENOMEM (Cannot allocate memory)
> close(3)                                = 0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
