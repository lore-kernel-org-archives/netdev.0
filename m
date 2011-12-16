From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH 5/6] de4x5/PCI: use list_for_each_entry() for bus->devices traversal
Date: Fri, 16 Dec 2011 14:34:24 -0800
Message-ID: <CANEJEGsm-vz767_98uaDT48mYwG_dJnUOmhqkgGPRqJpHhiFDA@mail.gmail.com>
References: <20111216223043.5963.87534.stgit@bhelgaas.mtv.corp.google.com>
	<20111216223154.5963.39965.stgit@bhelgaas.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, linux-pci@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>,
	netdev@vger.kernel.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20111216223154.5963.39965.stgit@bhelgaas.mtv.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2011 at 2:31 PM, Bjorn Helgaas <bhelgaas@google.com> wr=
ote:
> Replace open-coded list traversal with list_for_each_entry().

Hi Bjorn,

I don't have any de4x5 devices to test this but it looks correct to me.

Thanks!
grant

>
> CC: Grant Grundler <grundler@parisc-linux.org>
> CC: netdev@vger.kernel.org
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
> =C2=A0drivers/net/ethernet/dec/tulip/de4x5.c | =C2=A0 =C2=A09 ++-----=
--
> =C2=A01 files changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/eth=
ernet/dec/tulip/de4x5.c
> index 871bcaa..3f5d3b9 100644
> --- a/drivers/net/ethernet/dec/tulip/de4x5.c
> +++ b/drivers/net/ethernet/dec/tulip/de4x5.c
> @@ -2127,14 +2127,9 @@ srom_search(struct net_device *dev, struct pci=
_dev *pdev)
> =C2=A0 =C2=A0 u_long iobase =3D 0; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Clear upper 32 bits in Alphas */
> =C2=A0 =C2=A0 int i, j;
> =C2=A0 =C2=A0 struct de4x5_private *lp =3D netdev_priv(dev);
> - =C2=A0 =C2=A0struct list_head *walk;
> -
> - =C2=A0 =C2=A0list_for_each(walk, &pdev->bus_list) {
> - =C2=A0 =C2=A0 =C2=A0 struct pci_dev *this_dev =3D pci_dev_b(walk);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* Skip the pci_bus list entry */
> - =C2=A0 =C2=A0 =C2=A0 if (list_entry(walk, struct pci_bus, devices) =
=3D=3D pdev->bus) continue;
> + =C2=A0 =C2=A0struct pci_dev *this_dev;
>
> + =C2=A0 =C2=A0list_for_each_entry(this_dev, &pdev->bus->devices, bus=
_list) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0vendor =3D this_dev->vendor;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0device =3D this_dev->device << 8;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(is_DC21040 || is_DC21041 || is_DC211=
40 || is_DC2114x)) continue;
>
