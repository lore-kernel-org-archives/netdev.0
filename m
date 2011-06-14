From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 06:34:10 -0400
Message-ID: <BANLkTik8+OK3QNreHLn7rqx-s4UXNypOEg@mail.gmail.com>
References: <cover.1308024069.git.joe@perches.com> <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Divy Le Ray <divy@chelsio.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jon Mason <jdmason@kudzu.us>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Dillow <dave@thedillows.
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59481 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab1FNKeb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 06:34:31 -0400
In-Reply-To: <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2011 at 12:02 AM, Joe Perches <joe@perches.com> wrote:

> diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e=
_main.c
> index 86a9122..c3c5db1 100644
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -800,8 +800,7 @@ static int atl1e_setup_ring_resources(struct atl1=
e_adapter *adapter)
> =A0 =A0 =A0 =A0/* Init TPD Ring */
> =A0 =A0 =A0 =A0tx_ring->dma =3D roundup(adapter->ring_dma, 8);
> =A0 =A0 =A0 =A0offset =3D tx_ring->dma - adapter->ring_dma;
> - =A0 =A0 =A0 tx_ring->desc =3D (struct atl1e_tpd_desc *)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (adapter->ring_vir_addr=
 + offset);
> + =A0 =A0 =A0 tx_ring->desc =3D adapter->ring_vir_addr + offset;
> =A0 =A0 =A0 =A0size =3D sizeof(struct atl1e_tx_buffer) * (tx_ring->co=
unt);
> =A0 =A0 =A0 =A0tx_ring->tx_buffer =3D kzalloc(size, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (tx_ring->tx_buffer =3D=3D NULL) {
> @@ -827,7 +826,7 @@ static int atl1e_setup_ring_resources(struct atl1=
e_adapter *adapter)
>
> =A0 =A0 =A0 =A0/* Init CMB dma address */
> =A0 =A0 =A0 =A0tx_ring->cmb_dma =3D adapter->ring_dma + offset;
> - =A0 =A0 =A0 tx_ring->cmb =A0 =A0 =3D (u32 *)(adapter->ring_vir_addr=
 + offset);
> + =A0 =A0 =A0 tx_ring->cmb =3D adapter->ring_vir_addr + offset;
> =A0 =A0 =A0 =A0offset +=3D sizeof(u32);
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < adapter->num_rx_queues; i++) {
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index 16249e9..24e1592 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -311,8 +311,7 @@ static s32 atl2_setup_ring_resources(struct atl2_=
adapter *adapter)
> =A0 =A0 =A0 =A0adapter->txd_dma =3D adapter->ring_dma ;
> =A0 =A0 =A0 =A0offset =3D (adapter->txd_dma & 0x7) ? (8 - (adapter->t=
xd_dma & 0x7)) : 0;
> =A0 =A0 =A0 =A0adapter->txd_dma +=3D offset;
> - =A0 =A0 =A0 adapter->txd_ring =3D (struct tx_pkt_header *) (adapter=
->ring_vir_addr +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset);
> + =A0 =A0 =A0 adapter->txd_ring =3D adapter->ring_vir_addr + offset;
>
> =A0 =A0 =A0 =A0/* Init TXS Ring */
> =A0 =A0 =A0 =A0adapter->txs_dma =3D adapter->txd_dma + adapter->txd_r=
ing_size;

atlx looks fine.

Acked-By: Chris Snook <chris.snook@gmail.com>
