From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Re: [PATCH] 8139too in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 22:15:22 +0800
Message-ID: <000001d01c5f$650f3270$2f2d9750$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	<shangh@realtek.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:59383 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbaLTOPs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 09:15:48 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I know your meaning.


Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
diff --git a/drivers/net/ethernet/realtek/8139too.c
b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..f277c5f 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -782,11 +782,11 @@ static struct net_device *rtl8139_init_board(stru=
ct
pci_dev *pdev)
 	rc =3D pci_enable_device (pdev);
 	if (rc)
 		goto err_out;
+	disable_dev_on_err =3D 1;
=20
 	rc =3D pci_request_regions (pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
-	disable_dev_on_err =3D 1;
=20
 	pci_set_master (pdev);
=20
@@ -1098,6 +1098,7 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 	return 0;
=20
 err_out:
+	netif_napi_del(&tp->napi);
 	__rtl8139_cleanup_dev (dev);
 	pci_disable_device (pdev);
 	return i;
@@ -1112,6 +1113,7 @@ static void rtl8139_remove_one(struct pci_dev *pd=
ev)
 	assert (dev !=3D NULL);
=20
 	cancel_delayed_work_sync(&tp->thread);
+	netif_napi_del(&tp->napi);
=20
 	unregister_netdev (dev);


-----=D3=CA=BC=FE=D4=AD=BC=FE-----
=B7=A2=BC=FE=C8=CB: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembed=
ded.com]=20
=B7=A2=CB=CD=CA=B1=BC=E4: 2014=C4=EA12=D4=C220=C8=D5 21:48
=CA=D5=BC=FE=C8=CB: Jia-Ju Bai; netdev@vger.kernel.org; jgarzik@pobox.c=
om;
shangh@realtek.com.tw
=D6=F7=CC=E2: Re: [PATCH] 8139too in linux-3.18.0: some potential bugs

On 12/20/2014 4:20 PM, Jia-Ju Bai wrote:

> I have actually tested 8139too driver on the real hardware(Realtek=20
> RTL8139D PCI Ethernet Controller), and find some potential bugs:
> The target file is drivers/net/ethernet/realtek/8139too.c, which is=20
> used to build 8139too.ko.

> (1) In the normal process of 8139too, netif_napi_add is called in=20
> rtl8139_init_one, but netif_napi_del is not called in rtl8139_remove_=
one.
> However, many other ethernet card drivers call them in pairs, even in=
=20
> the error handling paths, such as r8169 and igb.

> (2) In the normal process of 8139too, pci_enable_device and=20
> pci_disable_device are called in pairs in rtl8139_init_board(in
> rtl8139_init_one) and rtl8139_remove_one. However, when=20
> pci_enable_device has been called and pci_request_regions is failed i=
n=20
> rtl8139_init_board, "err_out" segment in rtl8139_init_board is=20
> executed immediately to exit, but pci_disable_device is not called be=
cause
"disable_dev_on_err =3D 0".

    Again, please fix one issue per patch.

> Meanwhile, I also write the patch to fix the bugs. I have run the=20
> patch on the hardware, it can work normally and fix the above bugs.

    Too bad you didn't provide a sign-off...

WBR, Sergei
