From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix slowness in read /proc/net/tcp
Date: Mon, 07 Jun 2010 00:55:56 -0700 (PDT)
Message-ID: <20100607.005556.71568723.davem@davemloft.net>
References: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
	<1275895167.2545.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org, iler.ml@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754279Ab0FGHzq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 03:55:46 -0400
In-Reply-To: <1275895167.2545.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 09:19:27 +0200

> Le dimanche 06 juin 2010 =E0 20:27 -0700, Tom Herbert a =E9crit :
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>=20
> This problem raises every year,  (last attempt from Yakov Lerner :
> http://kerneltrap.org/mailarchive/linux-netdev/2009/9/26/6256119 )
>=20
> And finally, someone motivated enough to use /proc/net/tcp found the
> right answer ;)
>=20
> Most netdev people tend to push inet_diag (netlink) interface instead=
 of
> old /proc/net/tcp, but it seems old interface will still be used in
> 2030, so :
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Indeed this is the best attempt of this I've seen so far,
applied to net-next-2.6, thanks Tom.

> BTW, another problem of /proc/net/tcp is the buffer size used by nets=
tat
> utility : 1024 bytes instead of PAGE_SIZE, making O(N^2) behavior eve=
n
> more palpable.

Probably cap it at 8K like we do for netlink atomic reads, because
there are all sorts of crazy PAGE_SIZE configurations possible out
there, even as high as 512K.
