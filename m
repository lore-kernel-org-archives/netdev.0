From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/3] netfilter: nat: snat created in route process just
 apply to routed traffic
Date: Sun, 31 Jul 2016 21:00:56 +0200
Message-ID: <20160731190056.GA14216@breakpoint.cc>
References: <1469915644-16861-1-git-send-email-xfan@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, Xiaoping Fan <xfan@codeaurora.org>
To: fxp2001640163@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43114 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750948AbcGaTBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 15:01:04 -0400
Content-Disposition: inline
In-Reply-To: <1469915644-16861-1-git-send-email-xfan@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fxp2001640163@gmail.com <fxp2001640163@gmail.com> wrote:
> From: Xiaoping Fan <xfan@codeaurora.org>
> 
> In some situations, packet goes through Linux twice, one for bridging,
> another for routing. If snat is created in bridging process, that means

Hmm, but SNAT happens in POSTROUTING.

Where can we enter routing path after bridge went though postrouting...?

Normally if bridge packet has local dst mac kb traversal is:

bridge prerouting -> bridge input -> ipv4 prerouting (hook invocation
suppressed via bridge netfilter sabotage hook)

Depending on route table we then end up in ipv4 input (again suppressed)
or in forward and postrouting.

What is the issue, exactly?
