From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 12/16] e1000: Modified e1000_clean::
 exit poll (fwd)
Date: Wed, 27 Apr 2005 11:28:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271127430.17876-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Modified e1000_clean:: exit poll if no Tx and work_done =3D=3D 0

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/d=
rivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c=A0=A0=A0=A0=A0 2005-04=
-11 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c=A0 2005-04-11 02:2=
2:29.000000000 -0700
@@ -2368,9 +2368,8 @@ e1000_clean(struct net_device *netdev, i
=A0=A0=A0=A0=A0=A0=A0 *budget -=3D work_done;
=A0=A0=A0=A0=A0=A0=A0 netdev->quota -=3D work_done;
=A0=A0=A0=A0=A0=A0=A0
-=A0=A0=A0=A0=A0=A0 /* if no Tx and not enough Rx work done, exit the pol=
ling mode */
-=A0=A0=A0=A0=A0=A0 if((!tx_cleaned && (work_done < work_to_do)) ||
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 !netif_running(netdev)) {
+=A0=A0=A0=A0=A0=A0 /* If no Tx and no Rx work done, exit the polling mod=
e */
+=A0=A0=A0=A0=A0=A0 if ((!tx_cleaned && (work_done =3D=3D 0)) || !netif_r=
unning(netdev)) {
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 netif_rx_complete(netdev);
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 e1000_irq_enable(adapter);
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 0;
