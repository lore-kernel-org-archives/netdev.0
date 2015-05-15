From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix udp checksums with raw sockets
Date: Thu, 14 May 2015 20:04:49 -0700
Message-ID: <1431659089.27831.87.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
	 <20150514.222732.1628575030241731130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, vyasevic@redhat.com,
	linux@stwm.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33161 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423143AbbEODEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 23:04:51 -0400
Received: by igbpi8 with SMTP id pi8so25385659igb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 20:04:51 -0700 (PDT)
In-Reply-To: <20150514.222732.1628575030241731130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 22:27 -0400, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Thu, 14 May 2015 20:34:08 -0400
> 
> > It was reported that trancerout6 would cause
> > a kernel to crash when trying to compute checksums
> > on raw UDP packets.  The cause was the check in
> > __ip6_append_data that would attempt to use
> > partial checksums on the packet.  However,
> > raw sockets do not initialize partial checksum
> > fields so partial checksums can't be used.
> > 
> > Solve this the same way IPv4 does it.  raw sockets
> > pass transhdrlen value of 0 to ip_append_data which
> > causes the checksum to be computed in software.  Use
> > the same check in ip6_append_data (check transhdrlen).
> > 
> > Reported-by: Wolfgang Walter <linux@stwm.de>
> > CC: Wolfgang Walter <linux@stwm.de>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> 
> Applied.... This seems like -stable material?  If so, how far
> back?

Arg, the Fixes: tag is missing :(

Fixes: 32dce968dd98 ("ipv6: Allow for partial checksums on non-ufo packets")
