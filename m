From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panic with 2.6.37-rc1
Date: Wed, 03 Nov 2010 23:11:21 +0100
Message-ID: <1288822281.2718.30.camel@edumazet-laptop>
References: <AANLkTi=mEzCMCC+K6oLOjW9xfws_+_hHq8DS3hpPB1zY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=mEzCMCC+K6oLOjW9xfws_+_hHq8DS3hpPB1zY@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 03 novembre 2010 =C3=A0 23:02 +0100, Tom Gundersen a =C3=A9=
crit :
> I get panic during boot both with 2.6.37-rc1 and with current head.
>=20
> Here is the error message:
> <http://www.lix.polytechnique.fr/~tom/2.6.37-rc1-panic.jpg>. My
> .config is below.
>=20
> Let me know if you want more info. If you want I can test patches or
> bisect (if no one has any better suggestions).
>=20

Please test following patch, thanks

[PATCH] atl1 : fix panic on load

Its now illegal to call netif_stop_queue() before register_netdev()

Reported-by: Tom Gundersen <teg@jklm.no>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/atlx/atl1.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 43579b3..5336310 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3043,7 +3043,6 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
 	atl1_pcie_patch(adapter);
 	/* assume we have no link for now */
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
=20
 	setup_timer(&adapter->phy_config_timer, atl1_phy_config,
 		    (unsigned long)adapter);
