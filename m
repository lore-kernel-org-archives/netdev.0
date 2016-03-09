From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 22:00:04 -0500 (EST)
Message-ID: <20160308.220004.1907883099752626015.davem@davemloft.net>
References: <23389.1457390714@warthog.procyon.org.uk>
	<29908.1457437197@warthog.procyon.org.uk>
	<24950.1457471469@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbcCIDAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 22:00:07 -0500
In-Reply-To: <24950.1457471469@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 08 Mar 2016 21:11:09 +0000

> I can put in a limit per peer, where a 'peer' is either a particular remote
> UDP port or particulat remote host.  TCP has this by virtue of having a
> limited number of ports available per IP address.  But if I have 10 IP
> addresses available, I can attempt to set up half a million TCP connections to
> a server simultaneously.  If I have access to a box that has an NFS mount on
> it, I can potentially open sufficient TCP ports that the NFS mount can't make
> a connection if it's not allowed to use privileged ports.

You must hold onto and commit locally to state for each and every one
of those remote TCP connections you create and actually move to
established state.

It's completely different, both sides have to make a non-trivial
resource commitment.

For this RXRPC stuff, you don't.

That's the important and critical difference.

My core argument still stands that RXRPC is fundamental DoS'able, in a
way that is not matched by TCP or our routing code or similar
subsystems.
