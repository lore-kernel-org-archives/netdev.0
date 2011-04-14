From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [net-next-2.6 04/24] e1000: convert to set_phys_id
Date: Wed, 13 Apr 2011 18:18:22 -0700
Message-ID: <1302743902.2950.181.camel@jtkirshe-MOBL1>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1302742940-22141-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <8DD2590731AB5D4C9DBF71A877482A90018A3428DE@orsmsx509.amr.corp.intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-cdDmX8duDk46Y35Ud7Af"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	stephen hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40917 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973Ab1DNBSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:18:23 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90018A3428DE@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cdDmX8duDk46Y35Ud7Af
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-04-13 at 18:12 -0700, Allan, Bruce W wrote:
> >-----Original Message-----
> >From:
> netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> >Behalf Of Jeff Kirsher
> >Sent: Wednesday, April 13, 2011 6:02 PM
> >To: davem@davemloft.net
> >Cc: stephen hemminger; netdev@vger.kernel.org; gospo@redhat.com;
> >bphilips@novell.com; Kirsher, Jeffrey T
> >Subject: [net-next-2.6 04/24] e1000: convert to set_phys_id
> >
> >From: stephen hemminger <shemminger@vyatta.com>
> >
> >Convert to new LED control infrastucture and remove no longer
> >necessary bits.
> >
> >Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> >Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >---
> > drivers/net/e1000/e1000.h         |    3 --
> > drivers/net/e1000/e1000_ethtool.c |   50
> ++++++++++++-------------------------
> > 2 files changed, 16 insertions(+), 37 deletions(-)
> >
> >diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
> >index a881dd0..f96475c 100644
> >--- a/drivers/net/e1000/e1000.h
> >+++ b/drivers/net/e1000/e1000.h
> >@@ -238,9 +238,6 @@ struct e1000_adapter {
> >       struct work_struct reset_task;
> >       u8 fc_autoneg;
> >
> >-      struct timer_list blink_timer;
> >-      unsigned long led_status;
> >-
> >       /* TX */
> >       struct e1000_tx_ring *tx_ring;      /* One per active queue */
> >       unsigned int restart_queue;
> >diff --git a/drivers/net/e1000/e1000_ethtool.c
> >b/drivers/net/e1000/e1000_ethtool.c
> >index dd70738..5c998a9 100644
> >--- a/drivers/net/e1000/e1000_ethtool.c
> >+++ b/drivers/net/e1000/e1000_ethtool.c
> >@@ -1753,46 +1753,28 @@ static int e1000_set_wol(struct net_device
> *netdev,
> >struct ethtool_wolinfo *wol)
> >       return 0;
> > }
> >
> >-/* toggle LED 4 times per second =3D 2 "blinks" per second */
> >-#define E1000_ID_INTERVAL     (HZ/4)
> >-
> >-/* bit defines for adapter->led_status */
> >-#define E1000_LED_ON          0
> >-
> >-static void e1000_led_blink_callback(unsigned long data)
> >+static int e1000_set_phys_id(struct net_device *netdev,
> >+                           enum ethtool_phys_id_state state)
> > {
> >-      struct e1000_adapter *adapter =3D (struct e1000_adapter *) data;
> >+      struct e1000_adapter *adapter =3D netdev_priv(netdev);
> >       struct e1000_hw *hw =3D &adapter->hw;
> >
> >-      if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
> >-              e1000_led_off(hw);
> >-      else
> >-              e1000_led_on(hw);
> >-
> >-      mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
> >-}
> >+      switch (state) {
> >+      case ETHTOOL_ID_ACTIVE:
> >+              e1000_setup_led(hw);
> >+              return -EINVAL;
>=20
> This conflicts with the patch I submitted a few hours ago - with it,
> this
> feature is broken for e1000.

Dave - I will remove this patch from my tree and send you an updated
pull request when my tree is updated.

--=-cdDmX8duDk46Y35Ud7Af
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNpkteAAoJECTsCADr/EWUqIgH/0HFo+ryMYwPbzlkMJOPOR/K
wUftFJm+nZ3qYenvM1Sy3stopnEiFvuiXhooZtgCYQOmz/6Xneo3RZGPmJlJS3NZ
KnDia3uRFSTXdU7t5vHurUNf7to68ev2yF2AngtH0Vg7CalMsKRktPLGTMwVOzDc
4zcPQWhBpqu3wY/nfgAXaPTC/KBvyf5AasmlgMffr8g1RK3WIAbXSoA4Fi7i82Ci
nCw+e0picuas3twqDQekRYwYKHDcWhdq7Rzk6IzRC0Za1Dj6HzUqr33elGGDUZ8u
3TjOi6ve5WA/gdgGLbC7voEohuUM+1AGd5/LG0zeFZKYhWL2Kpp+o+yf3kJ3hCQ=
=8MQY
-----END PGP SIGNATURE-----

--=-cdDmX8duDk46Y35Ud7Af--

