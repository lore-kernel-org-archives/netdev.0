From: Wang Shaoyan <stufever@gmail.com>
Subject: Re: [PATCH] ATM: Delete no use FILL_RX_POOLS_IN_BH marco
Date: Fri, 5 Aug 2011 20:20:34 +0800
Message-ID: <CANxBZFrpFAK0iN0MXxfxkz=HwmU+4Zw275L0BJzy6cTEuZ0v4Q@mail.gmail.com>
References: <1310130103-4847-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:50668 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab1HEMUe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 08:20:34 -0400
Received: by pzk37 with SMTP id 37so3824900pzk.1
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2011 05:20:34 -0700 (PDT)
In-Reply-To: <1310130103-4847-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

applied

2011/7/8  <stufever@gmail.com>:
> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>
> The macro FILL_RX_POOLS_IN_BH is never been used, in order to avoid
> the compiler reports error because of the usage of function INIT_WORK=
,
> we just delete the marco.
>
> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
> Cc: linux-atm-general@lists.sourceforge.net
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
> ---
> =A0drivers/atm/ambassador.c | =A0 11 +----------
> =A0drivers/atm/ambassador.h | =A0 =A04 ----
> =A02 files changed, 1 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
> index a5fcb1e..bb3b016 100644
> --- a/drivers/atm/ambassador.c
> +++ b/drivers/atm/ambassador.c
> @@ -813,7 +813,7 @@ static void fill_rx_pool (amb_dev * dev, unsigned=
 char pool,
> =A0 return;
> =A0}
>
> -// top up all RX pools (can also be called as a bottom half)
> +// top up all RX pools
> =A0static void fill_rx_pools (amb_dev * dev) {
> =A0 unsigned char pool;
>
> @@ -872,11 +872,7 @@ static irqreturn_t interrupt_handler(int irq, vo=
id *dev_id) {
> =A0 =A0 =A0 ++irq_work;
>
> =A0 =A0 if (irq_work) {
> -#ifdef FILL_RX_POOLS_IN_BH
> - =A0 =A0 =A0schedule_work (&dev->bh);
> -#else
> =A0 =A0 =A0 fill_rx_pools (dev);
> -#endif
>
> =A0 =A0 =A0 PRINTD (DBG_IRQ, "work done: %u", irq_work);
> =A0 =A0 } else {
> @@ -2154,11 +2150,6 @@ static void setup_dev(amb_dev *dev, struct pci=
_dev *pci_dev)
> =A0 =A0 =A0 dev->tx_avail =3D ATM_OC3_PCR;
> =A0 =A0 =A0 dev->rx_avail =3D ATM_OC3_PCR;
>
> -#ifdef FILL_RX_POOLS_IN_BH
> - =A0 =A0 =A0// initialise bottom half
> - =A0 =A0 =A0INIT_WORK(&dev->bh, (void (*)(void *)) fill_rx_pools, de=
v);
> -#endif
> -
> =A0 =A0 =A0 // semaphore for txer/rxer modifications - we cannot use =
a
> =A0 =A0 =A0 // spinlock as the critical region needs to switch proces=
ses
> =A0 =A0 =A0 mutex_init(&dev->vcc_sf);
> diff --git a/drivers/atm/ambassador.h b/drivers/atm/ambassador.h
> index bd1c46a..aa97105 100644
> --- a/drivers/atm/ambassador.h
> +++ b/drivers/atm/ambassador.h
> @@ -630,10 +630,6 @@ struct amb_dev {
> =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0iobase;
> =A0 u32 * =A0 =A0 =A0 =A0 =A0 =A0membase;
>
> -#ifdef FILL_RX_POOLS_IN_BH
> - =A0struct work_struct bh;
> -#endif
> -
> =A0 amb_cq =A0 =A0 =A0 =A0 =A0 cq;
> =A0 amb_txq =A0 =A0 =A0 =A0 =A0txq;
> =A0 amb_rxq =A0 =A0 =A0 =A0 =A0rxq[NUM_RX_POOLS];
> --
> 1.7.4.1
>
>



--=20
Wang Shaoyan
