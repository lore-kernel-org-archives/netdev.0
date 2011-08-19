From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH 67/75] et131x: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 18:59:53 +0100
Message-ID: <CANK3SE2zOO2TwiF=vSrGRB=D6=MZdwMywe2mTkUBn56XJdPXfg@mail.gmail.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	<1313760467-8598-67-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Alan Cox <alan@linux.intel.com>, devel@driverdev.osuosl.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760467-8598-67-git-send-email-ian.campbell@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 August 2011 14:27, Ian Campbell <ian.campbell@citrix.com> wrote:
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: Mark Einon <mark.einon@gmail.com>
> Cc: Alan Cox <alan@linux.intel.com>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-kernel@vger.kernel.org
> ---
> =A0drivers/staging/et131x/et1310_tx.c | =A0 12 ++++++------
> =A01 files changed, 6 insertions(+), 6 deletions(-)

Just a heads up - This patch is going to create some merge issues
if/when the outstanding changes I've sent for inclusion in the staging
tree get merged back.
Should be fairly trivial to fix though.

Cheers,
Mark

>
> diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et1=
31x/et1310_tx.c
> index 8fb3051..03e7a4e 100644
> --- a/drivers/staging/et131x/et1310_tx.c
> +++ b/drivers/staging/et131x/et1310_tx.c
> @@ -519,12 +519,12 @@ static int nic_send_packet(struct et131x_adapte=
r *etdev, struct tcb *tcb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * returned by pci_map=
_page() is always 32-bit
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * addressable (as def=
ined by the pci/dma subsystem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc[frag++].addr_lo =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_map_page(et=
dev->pdev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0frags[i - 1].page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0frags[i - 1].page_offset,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0frags[i - 1].size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0PCI_DMA_TODEVICE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc[frag++].addr_lo =3D=
 skb_frag_dma_map(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &etdev->pdev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &frags[i - 1],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frags[i - 1].size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_TODEVICE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> --
> 1.7.2.5
>
>
