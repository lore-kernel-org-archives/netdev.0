From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: SCTP length validation.
Date: Sun, 22 Jun 2008 12:32:32 -0700 (PDT)
Message-ID: <20080622.123232.71141502.davem@davemloft.net>
References: <20080620.221205.183623344.davem@davemloft.net>
	<485D2467.7020300@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753995AbYFVTcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 15:32:32 -0400
In-Reply-To: <485D2467.7020300@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Sat, 21 Jun 2008 11:55:19 -0400

> The same vulnerability also exists in sctp_getsockopt_peer_addrs_old().
> It's a bit more difficult to trigger since there is a dependency on
> the peer being multihomed as well, but it's still possible to cause the
> overwrite.

I can't see how that's possible.  This case looks harmless to
me.

The kernel side accesses are perfectly protected.  The kernel
will only access the actual address list stored via:

	list_for_each_entry(from, &asoc->peer.transport_addr_list,
				transports) {
 ...
		cnt ++;
		if (cnt >= getaddrs.addr_num) break;
	}
	getaddrs.addr_num = cnt;

Copies are only made to userspace, and the given ->addr_num only
serves as an early break-out from that loop.  I mean, take a look,
those lines in the above are the only aaccesses made to the user's
provided addr_num value.

There is no possibility to use strange ->addr_num values
in order to read or write kernel memory outside of the
intended bounds.

I don't even see any value to adding new checks here.
