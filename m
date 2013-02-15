From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/6] udp: add encapsulation socket destroy hook
Date: Fri, 15 Feb 2013 16:02:36 -0500 (EST)
Message-ID: <20130215.160236.126363484380703537.davem@davemloft.net>
References: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3BOVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 16:02:39 -0500
In-Reply-To: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Fri, 15 Feb 2013 10:25:13 +0000

> While working on an issue in l2tp relating to tunnel cleanup I discovered a
> problem which I think may require a new hook in udp core to resolve.  The l2tp
> code uses encapsulated udp sockets, and it needs to know when a socket is
> being closed in order to clean up.  Since sessions hold a reference to the
> tunnel socket, hooking sk_destruct isn't sufficient: any tunnel with sessions
> running in it will be pinned open by the sessions.
> 
> To resolve this, the first patch in this series adds a .destroy hook to udp, 
> while the following patches show how I'd use this feature in l2tp.  Essentially 
> the .destroy callback is used to close the sessions in the tunnel, thereby 
> dropping the socket references.
> 
> Does this seem like a reasonable approach?  I'm reluctant to modify udp, but
> I've not managed to discover a safe alternative...

For now this is fine by me.

If we commonly start to encapsulate in other datagram protocols we'll
need to facilitate this more generically, perhaps by having something
that hooks in near the sk_prot->destroy() in sk_release_common().
