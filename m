From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Phonet: small pipe protocol fixes
Date: Fri, 25 Feb 2011 11:24:06 -0800 (PST)
Message-ID: <20110225.112406.246526410.davem@davemloft.net>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
	<20110225.112055.260096987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ofono@ofono.org
To: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753076Ab1BYTX3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 14:23:29 -0500
In-Reply-To: <20110225.112055.260096987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Fri, 25 Feb 2011 11:20:55 -0800 (PST)

> From: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
> Date: Fri, 25 Feb 2011 11:13:41 +0200
>=20
>> This patch series cleans up and fixes a number of small bits in the
>> Phonet pipe code, especially the experimental pipe controller. Once
>> this small bits are sorted out, I will try to fix the controller
>> protocol implementation proper so that we do not need the
>> compile-time (experimental) flag anymore.
>=20
> All applied thanks.
>=20
> If you want to start using GIT to push phonet changes to me, frankly =
I
> would welcome that :-)

BTW, I had to add the following patch to fix a build warning:

--------------------
phonet: Protect pipe_do_remove() with appropriate ifdefs.

It is only used when CONFIG_PHONET_PIPECTRLR is not set.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/phonet/pep.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index b8c31fc..875e86c 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -849,6 +849,7 @@ drop:
 	return err;
 }
=20
+#ifndef CONFIG_PHONET_PIPECTRLR
 static int pipe_do_remove(struct sock *sk)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
@@ -870,6 +871,7 @@ static int pipe_do_remove(struct sock *sk)
=20
 	return pn_skb_send(sk, skb, NULL);
 }
+#endif
=20
 /* associated socket ceases to exist */
 static void pep_sock_close(struct sock *sk, long timeout)
--=20
1.7.4.1

