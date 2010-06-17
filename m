From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: bnx2 fails to compile on parisc because of missing get_dma_ops()
Date: Wed, 16 Jun 2010 21:17:15 -0400
Message-ID: <AANLkTilSfOwwT87mgDcWBogL4gPnM7VBTOALKpZv_upN@mail.gmail.com>
References: <1276737229.2847.853.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Michael Chan <mchan@broadcom.com>
To: James Bottomley <JBottomley@novell.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1276737229.2847.853.camel@mulgrave.site>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2010 at 9:13 PM, James Bottomley wrote:
> I'm not quite sure whose fault this one is.
>
> However, this code in bnx2.c:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!get_dma_ops(&pdev->dev)->sync_sin=
gle_for_cpu) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next_rx_buf =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&rxr->=
rx_buf_ring[
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetch(next_rx_buf->=
desc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> Looks remarkably fragile: what exactly is it trying to do?
>
> The commit that causes the problem:
>
> commit a33fa66bcf365ffe5b79d1ae1d3582cc261ae56e
> Author: Michael Chan <mchan@broadcom.com>
> Date: =A0 Thu May 6 08:58:13 2010 +0000
>
> =A0 =A0bnx2: Add prefetches to rx path.
>
> Looks fairly innocuous by the description.
>
> Should parisc have a get_dma_ops()? =A0We don't need one because our =
dma
> ops are per platform not per bus.

looks like it'll be broken on more than just parisc:
$ grep get_dma_ops arch/*/include/asm/ -rl | cut -d/ -f 2
alpha
ia64
microblaze
powerpc
sh
sparc
x86
-mike
--
To unsubscribe from this list: send the line "unsubscribe linux-parisc"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
