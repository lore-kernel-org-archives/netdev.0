From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen: netfront: ethtool stats fields should be unsigned
 long
Date: Tue, 15 Mar 2011 04:50:43 +0100
Message-ID: <1300161043.2649.33.camel@edumazet-laptop>
References: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
	 <20110314.151029.200378268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org, jeremy@goop.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50808 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab1CODur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 23:50:47 -0400
Received: by wwk4 with SMTP id 4so2403555wwk.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 20:50:46 -0700 (PDT)
In-Reply-To: <20110314.151029.200378268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 15:10 -0700, David Miller a =C3=A9crit :
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Thu, 10 Mar 2011 17:04:18 +0000
>=20
> > Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to be
> > unsigned long as suggested by Ben Hutchings in
> > <1298919198.2569.14.camel@bwh-desktop>
> >=20
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>=20
> Applied, thanks Ian.

Hmm, this needs this followup patch then.

Thanks

[PATCH] xen: netfront: fix xennet_get_ethtool_stats()

commit e9a799ea4a5551d2 (xen: netfront: ethtool stats fields should be
unsigned long) made rx_gso_checksum_fixup an unsigned long.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 27cf72f..5b399b5 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1692,7 +1692,7 @@ static void xennet_get_ethtool_stats(struct net_d=
evice *dev,
 	int i;
=20
 	for (i =3D 0; i < ARRAY_SIZE(xennet_stats); i++)
-		data[i] =3D *(int *)(np + xennet_stats[i].offset);
+		data[i] =3D *(unsigned long *)(np + xennet_stats[i].offset);
 }
=20
 static void xennet_get_strings(struct net_device *dev, u32 stringset, =
u8 * data)


