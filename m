From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Sun, 27 Sep 2015 10:10:55 +0200
Message-ID: <20150927081055.GA17055@breakpoint.cc>
References: <1443112224-574543-1-git-send-email-tom@herbertland.com>
 <20150926.231554.1860934088223264189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35352 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755035AbbI0ILB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 04:11:01 -0400
Content-Disposition: inline
In-Reply-To: <20150926.231554.1860934088223264189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> > This patch set addresses the issue for ILA by adding a fast locator
> > lookup that occurs before early demux. This is done by using a hook
> > at NF_INET_PRE_ROUTING. For the backend we implement an rhashtable
> > that contains identifier to locator to mappings. The table also
> > allows more specific matches that include original locator and
> > interface.
> 
> I really don't think we should use netfilter hooks to perform
> operations setup outside of netfilter's normal configuration
> mechanisms.

Thanks, thats my thinking as well.

> If ILA were instead configured inside of netfilter's normal mechanisms
> then there would be full transparency about whether ILA
> transformations are performed before or after the user's other
> netfilter rules.  And the user would have full control over this.
> As implemented here, they don't.
> 
> So sorry, I'm not too keen on this and I bet if netfilter developers
> reviewed this patch series they'd have similar objections.

Seems this should/could be implemented similar to RFC6296 network
prefix translations (see net/ipv6/netfilter/ip6t_NPT.c).
