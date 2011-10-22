From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY
 setsockopt
Date: Sat, 22 Oct 2011 00:04:06 -0400 (EDT)
Message-ID: <20111022.000406.350185785547409199.davem@davemloft.net>
References: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab1JVEEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 00:04:12 -0400
In-Reply-To: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Fri, 21 Oct 2011 15:22:05 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> This change adds a sysctl (/proc/sys/net/core/allow_so_priority)
> with a default of true (1), as such it does not change the default
> behaviour of the Linux kernel.
>=20
> This sysctl can be set to false (0), this will result in non
> CAP_NET_ADMIN processes being unable to set SO_PRIORITY socket
> option.
>=20
> This is desireable if we want to rely on socket/skb priorities
> being inferred from TOS/TCLASS bits.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

The socket layer is not the place to enforce this.

The ingress into your MPLS/RSVP cloud that actually provides the
quality of service is where you control and mangle the TOS as needed.

Sorry, I'm not applying anything like this.  Any machine on your
network can spit out any TOS it wants, and if you have control over
the apps change it's behavior there.  If you don't have control over
the apps then filter and mangle.
