From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix udp checksums with raw sockets
Date: Thu, 14 May 2015 18:24:15 -0700
Message-ID: <1431653055.27831.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
	Wolfgang Walter <linux@stwm.de>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33642 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030197AbbEOBYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 21:24:31 -0400
Received: by iebgx4 with SMTP id gx4so78708963ieb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 18:24:31 -0700 (PDT)
In-Reply-To: <1431650048-16189-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 20:34 -0400, Vladislav Yasevich wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
