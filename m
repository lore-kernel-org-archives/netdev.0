From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH,v2] Re: e1000e: why does pci_enable_pcie_error_reporting()
	fail on my hp2510p?
Date: Tue, 1 Sep 2009 18:18:52 -0700
Message-ID: <9929d2390909011818r1acf646ct8a1d5ad57b0e2bfd@mail.gmail.com>
References: <200908201714.30638.elendil@planet.nl>
	 <200908210829.10471.elendil@planet.nl> <4A8E3FC1.50201@redhat.com>
	 <200908210848.39377.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Danny Feng <dfeng@redhat.com>, Netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755514AbZIBBSy@vger.kernel.org>
In-Reply-To: <200908210848.39377.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 20, 2009 at 23:48, Frans Pop<elendil@planet.nl> wrote:
> On Friday 21 August 2009, Danny Feng wrote:
>> You may also need to silence pci_disable_pcie_error_reporting,
>> otherwise rmmod/shutdown, you will get
>>
>> e1000e 0000:00:19.0: pci_disable_pcie_error_reporting failed
>
> Yes, thanks. Exactly the same thing there. Updated patch below.
>
>
> From: Frans Pop <elendil@planet.nl>
> Subject: net: Don't report an error if devices don't support AER
>
> The only error returned by pci_{en,dis}able_pcie_error_reporting() is
> -EIO which simply means that Advanced Error Reporting is not supporte=
d.
> There is no need to report that, so remove the error check from e1001=
e,
> igb and ixgbe.
>
> Signed-off-by: Frans Pop <elendil@planet.nl>
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index fa92a68..d67798f 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4983,12 +4983,7 @@ static int __devinit e1000_probe(struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_pci_r=
eg;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AER (Advanced Error Reporting) hooks */
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_pcie_error_reporting(pdev);
> - =C2=A0 =C2=A0 =C2=A0 if (err) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
, "pci_enable_pcie_error_reporting failed "
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "0x%x\n", err);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* non-fatal, cont=
inue */
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 pci_enable_pcie_error_reporting(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* PCI config space info */
> @@ -5301,9 +5296,6 @@ static void __devexit e1000_remove(struct pci_d=
ev *pdev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AER disable */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D pci_disable_pcie_error_reporting(p=
dev);
> - =C2=A0 =C2=A0 =C2=A0 if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "pci_disable_pcie_error_reporting failed 0x%x\n", err);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> =C2=A0}
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index adb09d3..1533d6f 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -1232,12 +1232,7 @@ static int __devinit igb_probe(struct pci_dev =
*pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_pci_r=
eg;
>
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_pcie_error_reporting(pdev);
> - =C2=A0 =C2=A0 =C2=A0 if (err) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
, "pci_enable_pcie_error_reporting failed "
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "0x%x\n", err);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* non-fatal, cont=
inue */
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 pci_enable_pcie_error_reporting(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_save_state(pdev);
> @@ -1668,9 +1663,6 @@ static void __devexit igb_remove(struct pci_dev=
 *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_netdev(netdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D pci_disable_pcie_error_reporting(p=
dev);
> - =C2=A0 =C2=A0 =C2=A0 if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "pci_disable_pcie_error_reporting failed 0x%x\n", err);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> =C2=A0}
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 77b0381..777556d 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5430,12 +5430,7 @@ static int __devinit ixgbe_probe(struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_pci_r=
eg;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_pcie_error_reporting(pdev);
> - =C2=A0 =C2=A0 =C2=A0 if (err) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
, "pci_enable_pcie_error_reporting failed "
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "0x%x\n", err);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* non-fatal, cont=
inue */
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 pci_enable_pcie_error_reporting(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_save_state(pdev);
> @@ -5795,9 +5790,6 @@ static void __devexit ixgbe_remove(struct pci_d=
ev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_netdev(netdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D pci_disable_pcie_error_reporting(p=
dev);
> - =C2=A0 =C2=A0 =C2=A0 if (err)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 "pci_disable_pcie_error_reporting failed 0x%x\n", err);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_disable_device(pdev);
> =C2=A0}

Patch looks fine

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
