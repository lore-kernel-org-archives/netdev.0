From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 20:57:52 +0200
Message-ID: <1427914672.1808691.248212501.09E2ACED@webmail.messagingengine.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
 <20150401.144036.1354401396349418295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:42368 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752910AbbDAS5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:57:53 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 3AFE020A58
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 14:57:49 -0400 (EDT)
In-Reply-To: <20150401.144036.1354401396349418295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Apr 1, 2015, at 20:40, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > In case we do need more specific fragmentation setup semantics we would
> > need to go with Jiri's approach. Currently we don't care about sk_mc_loop
> > for kernel sockets, so it is easy to just shut them up. Other options
> > are safe as well.
> > 
> > Please review carefully!
> 
> As a short term solution I guess this is fine.
> 
> I'll let this sit for a day or two so others can review the change.

Ok, thanks!

We seem to have the same problem with skb->ignore_df which we
conditionally set by user request but multiple layer (e.g. tunnels) do
evaluate this boolean during stack traversal. IPv4 seems to be impacted
here as well, but I have to do more research on that. Maybe the
semantics seem to be wanted?

Bye,
Hannes
