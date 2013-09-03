From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Tue, 03 Sep 2013 11:19:14 -0600
Message-ID: <52261A12.3060203@wwwdotorg.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Fabio Estevam <festevam@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:50589 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022Ab3ICRTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:19:17 -0400
In-Reply-To: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 05:37 AM, Thomas Graf wrote:
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

Tested-by: Stephen Warren <swarren@nvidia.com>

Although I do note something slightly odd:

next-20130830 had an issue, and reverting V1 of this patch solved it.

However, in next-20130903, if I revert the revert of V1 of this patch, I
don't see any issue; it appears that the problem was some interaction
between V1 of this patch and something else in next-20130830.

Either way, this patch doesn't seem to introduce any issue when applied
on top of either next-20130830 with V1 reverted, or on top of
next-20130903, so it's fine.
