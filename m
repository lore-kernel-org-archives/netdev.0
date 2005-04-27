From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 8/11] ixgb: Remove hook for suspend,
 no power management (fwd)
Date: Wed, 27 Apr 2005 10:50:53 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271050330.16913-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Remove hook for suspend. No power management in 10GbE Controllers
=A0
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/dri=
vers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c=A0=A0=A0=A0=A0=A0=A0 200=
5-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c=A0=A0=A0 2005-04-05 =
23:06:38.283932752 -0700
@@ -120,33 +120,20 @@ static int ixgb_change_mtu(struct net_de
=A0static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t =
vid);
=A0static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
=A0
-static int ixgb_notify_reboot(struct notifier_block *, unsigned long eve=
nt,
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0 void *ptr);
-static int ixgb_suspend(struct pci_dev *pdev, uint32_t state);
-
=A0#ifdef CONFIG_NET_POLL_CONTROLLER
=A0/* for netdump / net console */
=A0static void ixgb_netpoll(struct net_device *dev);
=A0#endif
=A0
-struct notifier_block ixgb_notifier_reboot =3D {
-=A0=A0=A0=A0=A0=A0 .notifier_call =3D ixgb_notify_reboot,
-=A0=A0=A0=A0=A0=A0 .next =3D NULL,
-=A0=A0=A0=A0=A0=A0 .priority =3D 0
-};
-
=A0/* Exported from other modules */
=A0
=A0extern void ixgb_check_options(struct ixgb_adapter *adapter);
=A0
=A0static struct pci_driver ixgb_driver =3D {
-=A0=A0=A0=A0=A0=A0 .name =3D ixgb_driver_name,
+=A0=A0=A0=A0=A0=A0 .name=A0=A0=A0=A0 =3D ixgb_driver_name,
=A0=A0=A0=A0=A0=A0=A0 .id_table =3D ixgb_pci_tbl,
-=A0=A0=A0=A0=A0=A0 .probe =3D ixgb_probe,
-=A0=A0=A0=A0=A0=A0 .remove =3D __devexit_p(ixgb_remove),
-=A0=A0=A0=A0=A0=A0 /* Power Managment Hooks */
-=A0=A0=A0=A0=A0=A0 .suspend =3D NULL,
-=A0=A0=A0=A0=A0=A0 .resume =3D NULL
+=A0=A0=A0=A0=A0=A0 .probe=A0=A0=A0 =3D ixgb_probe,
+=A0=A0=A0=A0=A0=A0 .remove=A0=A0 =3D __devexit_p(ixgb_remove),
=A0};
=A0
=A0MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -169,17 +179,12 @@ MODULE_LICENSE("GPL");
=A0static int __init
=A0ixgb_init_module(void)
=A0{
-=A0=A0=A0=A0=A0=A0 int ret;
=A0=A0=A0=A0=A0=A0=A0 printk(KERN_INFO "%s - version %s\n",
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0 ixgb_driver_string, ixgb_driver_=
version);
=A0
=A0=A0=A0=A0=A0=A0=A0 printk(KERN_INFO "%s\n", ixgb_copyright);
=A0
-=A0=A0=A0=A0=A0=A0 ret =3D pci_module_init(&ixgb_driver);
-=A0=A0=A0=A0=A0=A0 if(ret >=3D 0) {
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 register_reboot_notifier(&ixgb_=
notifier_reboot);
-=A0=A0=A0=A0=A0=A0 }
-=A0=A0=A0=A0=A0=A0 return ret;
+=A0=A0=A0=A0=A0=A0 return pci_module_init(&ixgb_driver);
=A0}
=A0
=A0module_init(ixgb_init_module);
@@ -194,7 +194,6 @@ module_init(ixgb_init_module);
=A0static void __exit
=A0ixgb_exit_module(void)
=A0{
-=A0=A0=A0=A0=A0=A0 unregister_reboot_notifier(&ixgb_notifier_reboot);
=A0=A0=A0=A0=A0=A0=A0 pci_unregister_driver(&ixgb_driver);
=A0}
=A0
@@ -2121,54 +2092,6 @@ ixgb_restore_vlan(struct ixgb_adapter *a
=A0=A0=A0=A0=A0=A0=A0 }
=A0}
=A0
-/**
- * ixgb_notify_reboot - handles OS notification of reboot event.
- * @param nb notifier block, unused
- * @param event Event being passed to driver to act upon
- * @param p A pointer to our net device
- **/
-static int
-ixgb_notify_reboot(struct notifier_block *nb, unsigned long event, void =
*p)
-{
-=A0=A0=A0=A0=A0=A0 struct pci_dev *pdev =3D NULL;
-
-=A0=A0=A0=A0=A0=A0 switch(event) {
-=A0=A0=A0=A0=A0=A0 case SYS_DOWN:
-=A0=A0=A0=A0=A0=A0 case SYS_HALT:
-=A0=A0=A0=A0=A0=A0 case SYS_POWER_OFF:
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 while ((pdev =3D pci_find_devic=
e(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (pci_d=
ev_driver(pdev) =3D=3D &ixgb_driver)
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 ixgb_suspend(pdev, 3);
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
-=A0=A0=A0=A0=A0=A0 }
-=A0=A0=A0=A0=A0=A0 return NOTIFY_DONE;
-}
-
-/**
- * ixgb_suspend - driver suspend function called from notify.
- * @param pdev pci driver structure used for passing to
- * @param state power state to enter
- **/
-static int
-ixgb_suspend(struct pci_dev *pdev, uint32_t state)
-{
-=A0=A0=A0=A0=A0=A0 struct net_device *netdev =3D pci_get_drvdata(pdev);
-=A0=A0=A0=A0=A0=A0 struct ixgb_adapter *adapter =3D netdev->priv;
-
-=A0=A0=A0=A0=A0=A0 netif_device_detach(netdev);
-
-=A0=A0=A0=A0=A0=A0 if(netif_running(netdev))
-=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ixgb_down(adapter, TRUE);
-
-=A0=A0=A0=A0=A0=A0 pci_save_state(pdev);
-
-=A0=A0=A0=A0=A0=A0 state =3D (state > 0) ? 3 : 0;
-=A0=A0=A0=A0=A0=A0 pci_set_power_state(pdev, state);
-=A0=A0=A0=A0=A0=A0 msec_delay(200);
-
-=A0=A0=A0=A0=A0=A0 return 0;
-}
-
=A0#ifdef CONFIG_NET_POLL_CONTROLLER
=A0/*
=A0 * Polling 'interrupt' - used by things like netconsole to send skbs
