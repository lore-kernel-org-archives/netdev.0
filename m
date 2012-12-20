From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH net-next] af_unix: MSG_TRUNC support for dgram sockets
Date: Thu, 20 Dec 2012 17:50:46 +0100
Message-ID: <CAKgNAkhzbRNvDLsDxYEJnET=Xi1S0eoB1-ER5GeiHE9OLY5bPA@mail.gmail.com>
References: <1329287109.2555.44.camel@edumazet-laptop> <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
 <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120215.145511.1269077904303781879.davem@davemloft.net> <1329902695.18384.101.camel@edumazet-laptop>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, piergiorgio.beruto@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:61128 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab2LTQvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 11:51:07 -0500
Received: by mail-ie0-f172.google.com with SMTP id c13so4877594ieb.17
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 08:51:06 -0800 (PST)
In-Reply-To: <1329902695.18384.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2012 at 10:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Piergiorgio Beruto expressed the need to fetch size of first datagram in
> queue for AF_UNIX sockets and suggested a patch against SIOCINQ ioctl.
>
> I suggested instead to implement MSG_TRUNC support as a recv() input
> flag, as already done for RAW, UDP & NETLINK sockets.
>
> len = recv(fd, &byte, 1, MSG_PEEK | MSG_TRUNC);
>
> MSG_TRUNC asks recv() to return the real length of the packet, even when
> is was longer than the passed buffer.
>
> There is risk that a userland application used MSG_TRUNC by accident
> (since it had no effect on af_unix sockets) and this might break after
> this patch.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
> CC: Michael Kerrisk <mtk.manpages@gmail.com>

Patch below to man-pages applied.

Thanks for CCing me, Eric.

Cheers,

Michael

--- a/man2/recv.2
+++ b/man2/recv.2
@@ -264,7 +264,7 @@ subsequent receive call will return the same data.
 For raw
 .RB ( AF_PACKET ),
 Internet datagram (since Linux 2.4.27/2.6.8),
-and netlink (since Linux 2.6.22) sockets:
+netlink (since Linux 2.6.22) and UNIX datagram (since Linux 3.4) sockets:
 return the real length of the packet or datagram,
 even when it was longer than the passed buffer.
 Not implemented for UNIX domain
