From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] ila: Optimization to preserve value of
 early demux
Date: Mon, 14 Dec 2015 16:19:53 -0500 (EST)
Message-ID: <20151214.161953.1429843640262699390.davem@davemloft.net>
References: <1449793173-4086221-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194AbbLNVTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:19:55 -0500
In-Reply-To: <1449793173-4086221-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 10 Dec 2015 16:19:29 -0800

> In the current implementation of ILA, LWT is used to perform
> translation on both the input and output paths. This is functional,
> however there is a big performance hit in the receive path. Early
> demux occurs before the routing lookup (a hit actually obviates the
> route lookup). Therefore the stack currently performs early
> demux before translation so that a local connection with ILA
> addresses is never matched. Note that this issue is not just
> with ILA, but pretty much any translated or encapsulated packet
> handled by LWT would miss the opportunity for early demux. Solving
> the general problem seems non trivial since we would need to move
> the route lookup before early demx thereby mitigating the value.
> 
> This patch set addresses the issue for ILA by adding a fast locator
> lookup that occurs before early demux. This done by hooking in to
> NF_INET_PRE_ROUTING
> 
> For the backend we implement an rhashtable that contains identifier
> to locator to mappings. The table also allows more specific matches
> that include original locator and interface.
 ...

Please address Florian's feedback wrt. which nf hook registry interface
should be used, and otherwise I think this series is ready to go.
