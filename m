From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the staging tree
Date: Wed, 3 Jun 2015 17:16:34 +1000
Message-ID: <20150603171634.2da4f45d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Q685ra.J_l.eM0uRwWv2ELw"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Johnny Kim <johnny.kim@atmel.com>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:57707 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbbFCHQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 03:16:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/Q685ra.J_l.eM0uRwWv2ELw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Greg,

After merging the staging tree, today's linux-next build (x86_64 allmodconf=
ig)
failed like this:

drivers/staging/wilc1000/wilc_wfi_cfgoperations.c:681:3: error: too few arg=
uments to function 'cfg80211_disconnected'
   cfg80211_disconnected(dev, pstrDisconnectNotifInfo->u16reason, pstrDisco=
nnectNotifInfo->ie,
   ^
In file included from drivers/staging/wilc1000/wilc_wfi_netdevice.h:40:0,
                 from drivers/staging/wilc1000/wilc_wfi_cfgoperations.h:11,
                 from drivers/staging/wilc1000/wilc_wfi_cfgoperations.c:13:
include/net/cfg80211.h:4584:6: note: declared here
 void cfg80211_disconnected(struct net_device *dev, u16 reason,
      ^

Caused by commit c5c77ba18ea6 ("staging: wilc1000: Add SDIO/SPI 802.11
driver") from the staging tree interacting with commit 80279fb7ba5b
("cfg80211: properly send NL80211_ATTR_DISCONNECTED_BY_AP in
disconnect") from the net-next tree.

I applied the below merge fix patch (I didn't know if it should be
"true" or "false" - advise would be nice).  However, there are still
way to many warnings from this driver, so I have disabled it again.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 3 Jun 2015 17:09:03 +1000
Subject: [PATCH] staging: wilc1000: fix call to cfg80211_disconnecteddue to=
 API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/staging/wilc1000/wilc_wfi_cfgoperations.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c b/drivers/st=
aging/wilc1000/wilc_wfi_cfgoperations.c
index f5eff0933e7d..1685669762e8 100644
--- a/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c
+++ b/drivers/staging/wilc1000/wilc_wfi_cfgoperations.c
@@ -679,7 +679,7 @@ static void CfgConnectResult(tenuConnDisconnEvent enuCo=
nnDisconnEvent,
 			pstrDisconnectNotifInfo->u16reason =3D 1;
 		}
 		cfg80211_disconnected(dev, pstrDisconnectNotifInfo->u16reason, pstrDisco=
nnectNotifInfo->ie,
-				      pstrDisconnectNotifInfo->ie_len, GFP_KERNEL);
+				      pstrDisconnectNotifInfo->ie_len, false, GFP_KERNEL);
=20
 	}
=20
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Q685ra.J_l.eM0uRwWv2ELw
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVbqnfAAoJEMDTa8Ir7ZwVQZMP/38mOdnObrfdaRP+ikGif2ou
rv8hy/q4KFaRhvVH0dSJQiQrW/9sZ77r0H4gDQcqHwOkdo2wtBxWW+TCXezbAX3f
ULIwviOh0oPuVisW3BkCyF4S5GekKPpr4cj6HUwjDKAnZZLGGblXg++Wte8qofB/
x56RGVs7eLxLMUtGJkBf5IUaNUcv9CtlzytFY/1xPFyWV55hDmXdrppNBTXQO1UF
lXvBPXbQKqHRzVTaTYEuoMzfHngCRJFp9WbpfMQ0gGkCR6hL1VVK/j3UeQ9EYaAe
gB9Lg1uQTPZo4QI/R5tWXqCtrMNo2ZDe92fNezHpT0czjTF4fZ70hLqOkBilLRza
iQFcAWk2a19YfARKYfAEhw8Ufy+VvHPwgQP0zFABXwwsw+KpQIENfuU0o5ZNMm7u
EagAnV9LBMdd/DQj3+B8ggmhaD+YxC6atYR3BbnuO9fjs9KZNxeA7xuv5/jaANdU
Sh86FdcQOoHlggtW+aWWB4BQ7vF+SMiD8JnXtGnnFl1Px6qpy4sats1CBnHax0G2
t0gn3l/qCpGFPu5ccgUMGAlS6aikHC2Vr1uY4EkJu8n3qBQsnJL4xm5D06gq+x5v
mU0l/n93nocbM8bpa+FCso3ZZFeZvHQpHKuGzthpdKQWdljh8cwhTegj03bQ5rxn
D6fklxTfJ/XeuMdJedyH
=/wua
-----END PGP SIGNATURE-----

--Sig_/Q685ra.J_l.eM0uRwWv2ELw--
