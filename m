From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] atm: remove a net_device_stats clear
Date: Wed, 18 Aug 2010 22:44:34 +0200
Message-ID: <1282164274.2328.2.camel@edumazet-laptop>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
	 <1282115064-3701-1-git-send-email-tklauser@distanz.ch>
	 <20100818083304.2ef2eea4@nehalam>
	 <20100818.131043.226780154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, tklauser@distanz.ch, linux@arm.linux.org.uk,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, error27@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46291 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab0HRUoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 16:44:39 -0400
In-Reply-To: <20100818.131043.226780154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 13:10 -0700, David Miller a =C3=A9=
crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 18 Aug 2010 08:33:04 -0700
>=20
> > On Wed, 18 Aug 2010 09:04:24 +0200
> > Tobias Klauser <tklauser@distanz.ch> wrote:
> >=20
> >> =20
> >> -	memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));
> >> +	memset(&dev->stats, 0, sizeof(struct net_device_stats));
> >=20
> > This is incorrect, just remove the memset.  The stats are initializ=
ed
> > when device is created.  The Linux device driver convention is to
> > keep stats when device is set down and brought back up; that is wha=
t
> > the majority of other drivers do.
>=20
> Yep, both the ether1 and ether3 patch have this problem.  Looks
> like we'll see v4 coming some :-)

To be fair, we accepted some bits like that in the past ;)

[PATCH net-next-2.6] atm: remove a net_device_stats clear

No need to clear device stats in lec_open()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/atm/lec.c |    1 -
1 file changed, 1 deletion(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index d98bde1..181d70c 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -220,7 +220,6 @@ static unsigned char *get_tr_dst(unsigned char *pac=
ket, unsigned char *rdesc)
 static int lec_open(struct net_device *dev)
 {
 	netif_start_queue(dev);
-	memset(&dev->stats, 0, sizeof(struct net_device_stats));
=20
 	return 0;
 }


