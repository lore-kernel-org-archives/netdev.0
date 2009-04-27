From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Proposed PARCH PCIE legacy I/O port free intel 10Gb NIC
	driver
Date: Mon, 27 Apr 2009 10:56:35 -0700
Message-ID: <9929d2390904271056x8d3ca98o9307bcb55efb9fd6@mail.gmail.com>
References: <AB661B51A8B54AF0A4D28FEF67718445@WINAK2QSSPDVFH>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: gouji-new <gouji.masayuki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:56839 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758244AbZD0R4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 13:56:37 -0400
Received: by yw-out-2324.google.com with SMTP id 5so36159ywb.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 10:56:36 -0700 (PDT)
In-Reply-To: <AB661B51A8B54AF0A4D28FEF67718445@WINAK2QSSPDVFH>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 12:42 AM, gouji-new
<gouji.masayuki@jp.fujitsu.com> wrote:
> Hi all
>
> Traditionally Intel based NIC drivers request I/O port even though it
> doesn't need that really.
>
> Intel PCIE 10Gb driver (ixgbe) also requests I/O port but it doesn't =
need it
> either.
>
> This is a little inconvenient situation because sometimes we have to =
handle
> those cards
> on the slots where any I/O space is not attached.
>
>
>
>
> So we made pach which makes ixgbe driver legacy I/O port free.
>
> Signed-off-by: Masayuki Gouji <gouji.masayuki@jp.fujitsu.com>
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 0188425..c816cf1 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3626,7 +3626,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_power_state(pdev, PCI_D0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_restore_state(pdev);
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_device(pdev);
> +
> + =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_device_mem(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_ER=
R "ixgbe: Cannot enable PCI device from "
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"suspend\n");
> @@ -4578,7 +4579,7 @@ static int __devinit ixgbe_probe(struct pci_dev=
 *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 pm_value =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 part_num, eec;
>
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_device(pdev);
> + =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_device_mem(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return err;
>
> @@ -4598,9 +4599,12 @@ static int __devinit ixgbe_probe(struct pci_de=
v
> *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_using_dac =
=3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_request_regions(pdev, ixgbe_driver=
_name);
> + =C2=A0 =C2=A0 =C2=A0 err =3D pci_request_selected_regions(pdev,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
pci_select_bars(pdev,
> IORESOURCE_MEM),
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
ixgbe_driver_name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
, "pci_request_regions failed 0x%x\n",
> err);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "pci_request_selected_regions failed 0x%x\n", err);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_pci_r=
eg;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -4845,7 +4849,8 @@ err_eeprom:
> =C2=A0err_ioremap:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_netdev(netdev);
> =C2=A0err_alloc_etherdev:
> - =C2=A0 =C2=A0 =C2=A0 pci_release_regions(pdev);
> + =C2=A0 =C2=A0 =C2=A0 pci_release_selected_regions(pdev,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_select_bars=
(pdev, IORESOURCE_MEM));
> =C2=A0err_pci_reg:
> =C2=A0err_dma:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> @@ -4897,7 +4902,8 @@ static void __devexit ixgbe_remove(struct pci_d=
ev
> *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ixgbe_release_hw_control(adapter);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iounmap(adapter->hw.hw_addr);
> - =C2=A0 =C2=A0 =C2=A0 pci_release_regions(pdev);
> + =C2=A0 =C2=A0 =C2=A0 pci_release_selected_regions(pdev,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_select_bars=
(pdev, IORESOURCE_MEM));
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DPRINTK(PROBE, INFO, "complete\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kfree(adapter->tx_ring);
> @@ -4950,7 +4956,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(str=
uct
> pci_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_ers_result_t result;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> - =C2=A0 =C2=A0 =C2=A0 if (pci_enable_device(pdev)) {
> + =C2=A0 =C2=A0 =C2=A0 if (pci_enable_device_mem(pdev)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0DPRINTK(PROBE,=
 ERR,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0"Cannot re-enable PCI device after reset.\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0result =3D PCI=
_ERS_RESULT_DISCONNECT;
>
>

Thanks for the patch.  I will add it to my tree along with my other
ixgbe patches and push it to Dave.

--=20
Cheers,
Jeff
