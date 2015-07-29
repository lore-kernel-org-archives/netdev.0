From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: suppress NETDEV_UP notification on address
 lifetime update
Date: Tue, 28 Jul 2015 23:38:55 -0700 (PDT)
Message-ID: <20150728.233855.1081514455386990046.davem@davemloft.net>
References: <1437927538-21703-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbG2Gi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:38:56 -0400
In-Reply-To: <1437927538-21703-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 26 Jul 2015 12:18:58 -0400

> This notification causes the FIB to be updated, which is not needed
> because the address already exists, and more importantly it may undo
> intentional changes that were made to the FIB after the address was
> originally added. (As a point of comparison, when an address becomes
> deprecated because its preferred lifetime expired, a notification on
> this chain is not generated.)
> 
> The motivation for this commit is fixing an incompatibility between
> DHCP clients which set and update the address lifetime according to
> the lease, and a commercial VPN client which replaces kernel routes
> in a way that outbound traffic is sent only through the tunnel (and
> disconnects if any further route changes are detected via netlink).
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Yeah, this makes sense, applied.

I bet the SCTP notifier could have ended up with dups in it's local
address list because of this.
