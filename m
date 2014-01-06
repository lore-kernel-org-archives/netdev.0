From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] tcp: metrics: Delete all entries matching a
 certain destination
Date: Mon, 06 Jan 2014 16:10:27 -0500 (EST)
Message-ID: <20140106.161027.1498450744291161306.davem@davemloft.net>
References: <1387109444-1104-4-git-send-email-christoph.paasch@uclouvain.be>
	<20131217.145751.53681780657108721.davem@davemloft.net>
	<20140102091823.GA31178@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ja@ssi.bg
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635AbaAFVK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:10:29 -0500
In-Reply-To: <20140102091823.GA31178@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Thu, 2 Jan 2014 10:18:23 +0100

> Do you mean that if no source-IP is given in the netlink command that all
> entries matching the dst should be deleted or rather only one of them (and that it
> would be non-deterministic which one)?

You would delete all of them, it's the only way to stay compatible with
the current code.

> Because, if I delete all of them, then "ip tcp_metrics flush PREFIX" of
> today's iproute2 will complain, because iproute2 expects that for each entry of
> "ip tcp_metrics show" a delete-call must be done.
> 
> But, the non-deterministic case also feels a bit odd to me.

iproute2 should not expect that if it doesn't specify a specific
source address, in fact it doesn't even know how to currently.  I
can't think of any other reasonable behavior.
