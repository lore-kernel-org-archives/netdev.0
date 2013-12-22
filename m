From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: vxlan: use custom ndo_change_mtu
 handler
Date: Sun, 22 Dec 2013 18:01:38 -0500 (EST)
Message-ID: <20131222.180138.1233577114547473304.davem@davemloft.net>
References: <1387322468-17368-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157Ab3LVXBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:01:40 -0500
In-Reply-To: <1387322468-17368-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 18 Dec 2013 00:21:08 +0100

> When adding a new vxlan device to an "underlying carrier" (here:
> dst->remote_ifindex), the MTU size assigned to the vxlan device
> is the MTU at setup time of the carrier - needed headroom, when
> adding a vxlan device w/o explicit carrier, then it defaults
> to 1500.
> 
> In case of an explicit carrier that supports jumbo frames, we
> currently cannot change vxlan MTU via ip(8) to > 1500 in
> post-setup time, as vxlan driver uses eth_change_mtu() as default
> method for manually setting MTU.
> 
> Hence, use a custom implementation that only falls back to
> eth_change_mtu() in case we didn't use a dev parameter on device
> setup time, and otherwise allow a max MTU setting of the carrier
> incl. adjustment for headroom.
> 
> Reported-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
