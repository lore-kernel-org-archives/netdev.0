From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix udp checksums with raw sockets
Date: Thu, 14 May 2015 22:27:32 -0400 (EDT)
Message-ID: <20150514.222732.1628575030241731130.davem@davemloft.net>
References: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, linux@stwm.de,
	eric.dumazet@gmail.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945937AbbEOC1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:27:33 -0400
In-Reply-To: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Thu, 14 May 2015 20:34:08 -0400

> It was reported that trancerout6 would cause
> a kernel to crash when trying to compute checksums
> on raw UDP packets.  The cause was the check in
> __ip6_append_data that would attempt to use
> partial checksums on the packet.  However,
> raw sockets do not initialize partial checksum
> fields so partial checksums can't be used.
> 
> Solve this the same way IPv4 does it.  raw sockets
> pass transhdrlen value of 0 to ip_append_data which
> causes the checksum to be computed in software.  Use
> the same check in ip6_append_data (check transhdrlen).
> 
> Reported-by: Wolfgang Walter <linux@stwm.de>
> CC: Wolfgang Walter <linux@stwm.de>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied.... This seems like -stable material?  If so, how far
back?
