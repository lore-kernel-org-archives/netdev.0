From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for
 neighbour discovery messages
Date: Wed, 04 Sep 2013 14:41:03 -0400 (EDT)
Message-ID: <20130904.144103.1597684778395131609.davem@davemloft.net>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, swarren@wwwdotorg.org,
	festevam@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236Ab3IDSlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:41:05 -0400
In-Reply-To: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue,  3 Sep 2013 13:37:01 +0200

> Allocating skbs when sending out neighbour discovery messages
> currently uses sock_alloc_send_skb() based on a per net namespace
> socket and thus share a socket wmem buffer space.
> 
> If a netdevice is temporarily unable to transmit due to carrier
> loss or for other reasons, the queued up ndisc messages will cosnume
> all of the wmem space and will thus prevent from any more skbs to
> be allocated even for netdevices that are able to transmit packets.
> 
> The number of neighbour discovery messages sent is very limited,
> use of alloc_skb() bypasses the socket wmem buffer size enforcement
> while the manual call to skb_set_owner_w() maintains the socket
> reference needed for the IPv6 output path.
> 
> This patch has orginally been posted by Eric Dumazet in a modified
> form.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, and queued up for -stable along with Cong Wang's ndisc_send_rs()
locking change.

Thanks.
