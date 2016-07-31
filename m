From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 3/3] netfilter: nat: don't assign a null snat rule to
 bridged traffic if no matching
Date: Sun, 31 Jul 2016 21:02:26 +0200
Message-ID: <20160731190226.GB14216@breakpoint.cc>
References: <1469915660-16904-1-git-send-email-xfan@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, Xiaoping Fan <xfan@codeaurora.org>
To: fxp2001640163@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43134 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750948AbcGaTC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 15:02:29 -0400
Content-Disposition: inline
In-Reply-To: <1469915660-16904-1-git-send-email-xfan@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fxp2001640163@gmail.com <fxp2001640163@gmail.com> wrote:
> From: Xiaoping Fan <xfan@codeaurora.org>
> 
> In some case, bridged packet will come back again for routing. When bridge
> netfilter is enabled, a null snat rule is assigned to bridged packet if no
> matching in nat chain. Then nat rule matching is skipped when packet comes
> back for routing. This result in private IP address exported to public
> network. So we don't assign a null snat rule to bridged traffic if no
> matching.

This looks bogus.

However, we already have issue with existing iptables nat vs nftables
nat.

So I think it might make sense to delay NULL binding allocation until
we confirm the conntrack so users don't have to rmmod iptable_nat
anymore when they use nftables as well.
