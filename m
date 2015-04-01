From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 15:26:28 -0400 (EDT)
Message-ID: <20150401.152628.244767664283924955.davem@davemloft.net>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
	<20150401.144036.1354401396349418295.davem@davemloft.net>
	<1427914672.1808691.248212501.09E2ACED@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbDAT0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 15:26:34 -0400
In-Reply-To: <1427914672.1808691.248212501.09E2ACED@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 01 Apr 2015 20:57:52 +0200

> We seem to have the same problem with skb->ignore_df which we
> conditionally set by user request but multiple layer (e.g. tunnels) do
> evaluate this boolean during stack traversal. IPv4 seems to be impacted
> here as well, but I have to do more research on that. Maybe the
> semantics seem to be wanted?

It's arguably a macro-level condition on the top-level packet when set.

So perhaps it's enough to just clear it when we encapsulate.
