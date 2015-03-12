From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Thu, 12 Mar 2015 14:26:21 -0400 (EDT)
Message-ID: <20150312.142621.1128728353472907283.davem@davemloft.net>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netdev@emagii.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbbCLS0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:26:23 -0400
In-Reply-To: <1426107673-45049-1-git-send-email-netdev@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I hate changes like this.

By making this a Kconfig options it cannot be dynamic, and every
distribution is going to have to scratch their head and decide
what to set this to.

That's seriously suboptimal.

If you want to change behavior based upon whether userspace is
managing the damn table, make it so the user doing so has to
ask for the new behavior at _RUN TIME_ via the netlink interface
or similar.

Picking the guard time itself at compile time is also undesirable.

And you don't even want a damn timer, what you want is for the
state of the entry to be frozen and for the user to "release"
it by either adjusting the state to something else or marking
in some other way to allow it to be unfrozen and released again.

Why put it to chance with some timeout?  Make things explicit.

I'm not applying this patch.
