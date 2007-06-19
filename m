From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] TIPC: Fix infinite loop in netlink handler
Date: Tue, 19 Jun 2007 23:32:47 +0200
Message-ID: <46784B7F.8050903@trash.net>
References: <20070619201834.GH4383@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, per.liden@ericsson.com,
	tipc-discussion@lists.sourceforge.net
To: Florian Westphal <fw-kernel@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34218 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbXFSVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 17:33:14 -0400
In-Reply-To: <20070619201834.GH4383@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> The tipc netlink config handler uses the nlmsg_pid from the
> request header as destination for its reply. If the application
> initialized nlmsg_pid to 0, the reply is looped back to the kernel,
> causing hangup. Fix: use nlmsg_pid of the skb that triggered the
> request.
> 
> -		genlmsg_unicast(rep_buf, req_nlh->nlmsg_pid);
> +		genlmsg_unicast(rep_buf, NETLINK_CB(skb).pid);


This is the second time we're seeing this bug within a few weeks,
maybe we should rename NETLINK_CB(skb).pid to dst_pid to avoid
similar confusion in the future? We could even rename nlmsg_pid
to nlmsg_src within the kernel, which should make it completely
clear what is being refered to.
