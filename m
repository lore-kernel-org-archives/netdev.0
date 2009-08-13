From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fix use of pci_enable_pcie_error_reporting
Date: Wed, 12 Aug 2009 21:54:39 -0700
Message-ID: <9929d2390908122154m373bf674u12c06ab413017ebf@mail.gmail.com>
References: <1249637774-32419-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.ronciak@intel.com, peter.p.waskiewicz.jr@intel.com,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:64606 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbZHMEyj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:54:39 -0400
In-Reply-To: <1249637774-32419-1-git-send-email-dfeng@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 7, 2009 at 02:36, Xiaotian Feng<dfeng@redhat.com> wrote:
> commit 111b9dc5 introduces pcie aer support for e1000e, but it is not
> reasonable to disable it in e1000_remove but enable it in e1000_resum=
e.
> This patch enables aer support in e1000_probe.
>
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> ---
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 16 ++++++++--------
> =C2=A01 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index 63415bb..e2f0304 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4670,14 +4670,6 @@ static int e1000_resume(struct pci_dev *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 /* AER (Advanced Error Reporting) hooks */
> - =C2=A0 =C2=A0 =C2=A0 err =3D pci_enable_pcie_error_reporting(pdev);
> - =C2=A0 =C2=A0 =C2=A0 if (err) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_err(&pdev->dev=
, "pci_enable_pcie_error_reporting failed "
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 "0x%x\n", err);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* non-fatal, cont=
inue */
> - =C2=A0 =C2=A0 =C2=A0 }
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_enable_wake(pdev, PCI_D3hot, 0);
> @@ -4990,6 +4982,14 @@ static int __devinit e1000_probe(struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_pci_r=
eg;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0/* AER (Advanced Error Reporting) hooks =
*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D pci_enable_pcie_error_reporting(=
pdev);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_err(&pde=
v->dev, "pci_enable_pcie_error_reporting failed "
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"0x%x\n", err);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* non-fatal=
, continue */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pci_set_master(pdev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* PCI config space info */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D pci_save_state(pdev);
> --
> 1.6.2.5
>
> --

I have added this to my tree for testing.  Sorry I did not respond earl=
ier.

Dave - I will make sure that the tabs/whitespace is correct.

--=20
Cheers,
Jeff
