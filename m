From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.4 9/16] e1000: stops working after
 resume (fwd)
Date: Wed, 27 Apr 2005 11:07:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271107020.17397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


e1000 stops working after resume, call pci_enable_device after pci_restor=
e_state - Modified Andrew Morton's patch

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/d=
rivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c=A0=A0=A0=A0=A0 2005-04=
-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c=A0 2005-04-12 23:0=
0:55.000000000 -0700
@@ -3128,9 +3128,10 @@ e1000_resume(struct pci_dev *pdev)
=A0=A0=A0=A0=A0=A0=A0 struct e1000_adapter *adapter =3D netdev->priv;
=A0=A0=A0=A0=A0=A0=A0 uint32_t manc, ret;
=A0
-=A0=A0=A0=A0=A0=A0 ret =3D pci_enable_device(pdev);
=A0=A0=A0=A0=A0=A0=A0 pci_set_power_state(pdev, 0);
=A0=A0=A0=A0=A0=A0=A0 pci_restore_state(pdev, adapter->pci_state);
+=A0=A0=A0=A0=A0=A0 ret =3D pci_enable_device(pdev);
+=A0=A0=A0=A0=A0=A0 pci_set_master(pdev);
=A0
=A0=A0=A0=A0=A0=A0=A0 pci_enable_wake(pdev, 3, 0);
=A0=A0=A0=A0=A0=A0=A0 pci_enable_wake(pdev, 4, 0); /* 4 =3D=3D D3 cold */
