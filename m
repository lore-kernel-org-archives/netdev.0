From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: [PATCH 1/5] ssb: Change fallback sprom to callback mechanism.
Date: Sat, 7 May 2011 19:24:18 +0200
Message-ID: <BANLkTinV+cuTr2cPvR2pBDE_C-2J4KwWcA@mail.gmail.com>
References: <1304771263-10937-1-git-send-email-hauke@hauke-m.de> <1304771263-10937-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:43402 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772Ab1EGRYj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 13:24:39 -0400
Received: by qyg14 with SMTP id 14so3246961qyg.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 10:24:38 -0700 (PDT)
In-Reply-To: <1304771263-10937-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

just some small small spelling nit-picks:

On 7 May 2011 14:27, Hauke Mehrtens <hauke@hauke-m.de> wrote:
> Some embedded devices like the Netgear WNDR3300 have two SSB based
> cards without an own sprom on the pci bus. We have to provide two
> different fallback sproms for these and this was not possible with th=
e
> old solution. In the bcm47xx architecture the sprom data is stored in
> the nvram in the main flash storage. The architecture code will be ab=
le
> to fill the sprom with the stored data based on the bus where the
> device was found.
>
> The bcm63xx code should to the same thing as before, just using the n=
ew

to -> do

> API.
>
> CC: Michael Buesch <mb@bu3sch.de>
> CC: netdev@vger.kernel.org
> CC: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
> =C2=A0arch/mips/bcm63xx/boards/board_bcm963xx.c | =C2=A0 16 +++++++++=
+++++--
> =C2=A0drivers/ssb/pci.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 16 +++++++++++-----
> =C2=A0drivers/ssb/sprom.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 26 +++++++++++++++-----------
> =C2=A0drivers/ssb/ssb_private.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +-
> =C2=A0include/linux/ssb/ssb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 +++-
> =C2=A05 files changed, 44 insertions(+), 20 deletions(-)
>
> diff --git a/arch/mips/bcm63xx/boards/board_bcm963xx.c b/arch/mips/bc=
m63xx/boards/board_bcm963xx.c
> index 8dba8cf..40b223b 100644
> --- a/arch/mips/bcm63xx/boards/board_bcm963xx.c
> +++ b/arch/mips/bcm63xx/boards/board_bcm963xx.c
> @@ -643,6 +643,17 @@ static struct ssb_sprom bcm63xx_sprom =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.boardflags_lo =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D 0x2848,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.boardflags_hi =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D 0x0000,
> =C2=A0};
> +
> +int bcm63xx_get_fallback_sprom(struct ssb_bus *bus, struct ssb_sprom=
 *out)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (bus->bustype =3D=3D SSB_BUSTYPE_PCI) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(out, &bcm63=
xx_sprom, sizeof(struct ssb_sprom));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR PF=
X "unable to fill SPROM for given bustype.\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> =C2=A0#endif
>
> =C2=A0/*
> @@ -793,8 +804,9 @@ void __init board_prom_init(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!board_get_mac_address(bcm63xx_sprom.i=
l0mac)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(bcm63xx=
_sprom.et0mac, bcm63xx_sprom.il0mac, ETH_ALEN);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(bcm63xx=
_sprom.et1mac, bcm63xx_sprom.il0mac, ETH_ALEN);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ssb_arch_set_f=
allback_sprom(&bcm63xx_sprom) < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_ERR "failed to register fallback SPROM\n");
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ssb_arch_regis=
ter_fallback_sprom(
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &bcm63xx_get_fallback_sprom) < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 printk(KERN_ERR PFX "failed to register fallback SPROM\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0#endif
> =C2=A0}
> diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
> index 6f34963..34955d1 100644
> --- a/drivers/ssb/pci.c
> +++ b/drivers/ssb/pci.c
> @@ -662,7 +662,6 @@ static int sprom_extract(struct ssb_bus *bus, str=
uct ssb_sprom *out,
> =C2=A0static int ssb_pci_sprom_get(struct ssb_bus *bus,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ssb_sprom *sprom)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 const struct ssb_sprom *fallback;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 *buf;
>
> @@ -707,10 +706,17 @@ static int ssb_pci_sprom_get(struct ssb_bus *bu=
s,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* All CRC attempts failed.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 * Maybe there is no SPROM on the device?
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* If we have a fallback, use that. */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 fallback =3D ssb_get_fallback_sprom();
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (fallback) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(sprom, fallback, sizeof(*spr=
om));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* Now we ask the arch code if there is some sprom
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0* avaliable for this device in some other storage */

avaliable -> available

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 err =3D ssb_fill_sprom_with_fallback(bus, sprom);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (err) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ssb_printk(KERN_WARNING PFX "WARNIN=
G: Using"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0" fallback SPROM failed (err %d)\n",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0err);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ssb_dprintk(KERN_DEBUG PFX "Using S=
PROM"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 " revision %d provided by"
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 " platform.\n", sprom->revision);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_free;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0}
> diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
> index 5f34d7a..20cd139 100644
> --- a/drivers/ssb/sprom.c
> +++ b/drivers/ssb/sprom.c
> @@ -17,7 +17,7 @@
> =C2=A0#include <linux/slab.h>
>
>
> -static const struct ssb_sprom *fallback_sprom;
> +static int(*get_fallback_sprom)(struct ssb_bus *dev, struct ssb_spro=
m *out);
>
>
> =C2=A0static int sprom2hex(const u16 *sprom, char *buf, size_t buf_le=
n,
> @@ -145,13 +145,14 @@ out:
> =C2=A0}
>
> =C2=A0/**
> - * ssb_arch_set_fallback_sprom - Set a fallback SPROM for use if no =
SPROM is found.
> + * ssb_arch_register_fallback_sprom - Registers a method providing a=
 fallback
> + * SPROM if no SPROM is found.
> =C2=A0*
> - * @sprom: The SPROM data structure to register.
> + * @sprom_callback: The callbcak function.

callbcak -> callback

> =C2=A0*
> - * With this function the architecture implementation may register a=
 fallback
> - * SPROM data structure. The fallback is only used for PCI based SSB=
 devices,
> - * where no valid SPROM can be found in the shadow registers.
> + * With this function the architecture implementation may register a=
 callback
> + * handler which wills the SPROM data structure. The fallback is onl=
y used for

wills -> fills

> + * PCI based SSB devices, where no valid SPROM can be found in the s=
hadow registers.
> =C2=A0*
> =C2=A0* This function is useful for weird architectures that have a h=
alf-assed SSB device
> =C2=A0* hardwired to their PCI bus.
> @@ -163,18 +164,21 @@ out:
> =C2=A0*
> =C2=A0* This function is available for architecture code, only. So it=
 is not exported.
> =C2=A0*/
> -int ssb_arch_set_fallback_sprom(const struct ssb_sprom *sprom)
> +int ssb_arch_register_fallback_sprom(int (*sprom_callback)(struct ss=
b_bus *bus, struct ssb_sprom *out))
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 if (fallback_sprom)
> + =C2=A0 =C2=A0 =C2=A0 if (get_fallback_sprom)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EEXIST=
;
> - =C2=A0 =C2=A0 =C2=A0 fallback_sprom =3D sprom;
> + =C2=A0 =C2=A0 =C2=A0 get_fallback_sprom =3D sprom_callback;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> -const struct ssb_sprom *ssb_get_fallback_sprom(void)
> +int ssb_fill_sprom_with_fallback(struct ssb_bus *bus, struct ssb_spr=
om *out)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return fallback_sprom;
> + =C2=A0 =C2=A0 =C2=A0 if (!get_fallback_sprom)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOENT;
> +
> + =C2=A0 =C2=A0 =C2=A0 return get_fallback_sprom(bus, out);
> =C2=A0}
>
> =C2=A0/* http://bcm-v4.sipsolutions.net/802.11/IsSpromAvailable */
> diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
> index 0331139..1a32f58 100644
> --- a/drivers/ssb/ssb_private.h
> +++ b/drivers/ssb/ssb_private.h
> @@ -171,7 +171,7 @@ ssize_t ssb_attr_sprom_store(struct ssb_bus *bus,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *buf, size_t count,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int (*sprom_check_crc)(const u16 *sprom, s=
ize_t size),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int (*sprom_write)(struct ssb_bus *bus, co=
nst u16 *sprom));
> -extern const struct ssb_sprom *ssb_get_fallback_sprom(void);
> +extern int ssb_fill_sprom_with_fallback(struct ssb_bus *bus, struct =
ssb_sprom *out);
>
>
> =C2=A0/* core.c */
> diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
> index 9659eff..045f72a 100644
> --- a/include/linux/ssb/ssb.h
> +++ b/include/linux/ssb/ssb.h
> @@ -404,7 +404,9 @@ extern bool ssb_is_sprom_available(struct ssb_bus=
 *bus);
>
> =C2=A0/* Set a fallback SPROM.
> =C2=A0* See kdoc at the function definition for complete documentatio=
n. */
> -extern int ssb_arch_set_fallback_sprom(const struct ssb_sprom *sprom=
);
> +extern int ssb_arch_register_fallback_sprom(
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int (*sprom_callba=
ck)(struct ssb_bus *bus,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ssb_sprom *=
out));
>
> =C2=A0/* Suspend a SSB bus.
> =C2=A0* Call this from the parent bus suspend routine. */
> --
> 1.7.4.1
>
>
>
