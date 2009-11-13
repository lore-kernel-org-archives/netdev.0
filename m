From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Lots of tcp_recvmsg warnings in kerneloops list
Date: Fri, 13 Nov 2009 18:34:57 +0100
Message-ID: <4AFD98C1.70102@gmail.com>
References: <20091113091013.2bef993e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45951 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbZKMRfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 12:35:04 -0500
In-Reply-To: <20091113091013.2bef993e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Has anyone looked into this? Is there a fix? Should it be sent to sta=
ble?
>=20
> http://kerneloops.org/searchweek.php?search=3Dtcp_recvmsg
> --

Only debugging AFAIK, no discoveries yet.




commit c62f4c453ab4b0240ab857bfd089da2c01ad91e7
Author: Arjan van de Ven <arjan@linux.intel.com>
Date:   Thu Oct 22 21:37:56 2009 -0700

    net: use WARN() for the WARN_ON in commit b6b39e8f3fbbb
   =20
    Commit b6b39e8f3fbbb (tcp: Try to catch MSG_PEEK bug) added a print=
k()
    to the WARN_ON() that's in tcp.c. This patch changes this combinati=
on
    to WARN(); the advantage of WARN() is that the printk message shows=
 up
    inside the message, so that kerneloops.org will collect the message=
=2E
   =20
    In addition, this gets rid of an extra if() statement.
   =20
    Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit b6b39e8f3fbbb31001b836afec87bcaf4811a7bf
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Mon Oct 19 19:41:06 2009 +0000

    tcp: Try to catch MSG_PEEK bug
   =20
    This patch tries to print out more information when we hit the
    MSG_PEEK bug in tcp_recvmsg.  It's been around since at least
    2005 and it's about time that we finally fix it.
   =20
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

