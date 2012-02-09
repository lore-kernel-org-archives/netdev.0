From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [PATCH 04/50] adi/blackfin: set addr_assign_type correctly if random
Date: Thu, 9 Feb 2012 11:28:01 +0800
Message-ID: <CAA_GA1dj+XiWpbgGTf4rff6cvU0jUwyc2wK5XVqJaM3SeqtxVA@mail.gmail.com>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<1328735457-29986-5-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Scott Jiang <scott.jiang@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43066 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582Ab2BID2C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 22:28:02 -0500
In-Reply-To: <1328735457-29986-5-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Danny,

On Thu, Feb 9, 2012 at 5:10 AM, Danny Kukawka <danny.kukawka@bisect.de>=
 wrote:
> Set the addr_assign_type for adi driver correctly to
> NET_ADDR_RANDOM if a random MAC address was generated.
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
>
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
> =C2=A0arch/blackfin/mach-bf518/boards/ezbrd.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf518/boards/tcm-bf518.c =C2=A0| =C2=A0 =C2=A0=
3 ++-
> =C2=A0arch/blackfin/mach-bf527/boards/ad7160eval.c | =C2=A0 =C2=A03 +=
+-
> =C2=A0arch/blackfin/mach-bf527/boards/cm_bf527.c =C2=A0 | =C2=A0 =C2=A0=
3 ++-
> =C2=A0arch/blackfin/mach-bf527/boards/ezbrd.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf527/boards/ezkit.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf527/boards/tll6527m.c =C2=A0 | =C2=A0 =C2=A0=
3 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/cm_bf537e.c =C2=A0| =C2=A0 =C2=A0=
3 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/cm_bf537u.c =C2=A0| =C2=A0 =C2=A0=
3 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/dnp5370.c =C2=A0 =C2=A0| =C2=A0=
 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/pnav10.c =C2=A0 =C2=A0 | =C2=A0=
 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/stamp.c =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 =C2=A03 ++-
> =C2=A0arch/blackfin/mach-bf537/boards/tcm_bf537.c =C2=A0| =C2=A0 =C2=A0=
3 ++-
> =C2=A0drivers/net/ethernet/adi/bfin_mac.c =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| =C2=A0 10 +++++++---
> =C2=A0drivers/net/ethernet/adi/bfin_mac.h =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| =C2=A0 =C2=A02 +-

Would you please split this into two patches, one for arch/blackfin
and the other
for drivers/net.
This can make our maintain simpler and clearer.

> =C2=A015 files changed, 34 insertions(+), 17 deletions(-)
>
> diff --git a/arch/blackfin/mach-bf518/boards/ezbrd.c b/arch/blackfin/=
mach-bf518/boards/ezbrd.c
> index a2d96d3..a173957 100644
> --- a/arch/blackfin/mach-bf518/boards/ezbrd.c
> +++ b/arch/blackfin/mach-bf518/boards/ezbrd.c
> @@ -821,7 +821,7 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the MAC is stored in OTP memory page 0x=
DF */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ret;
> @@ -834,5 +834,6 @@ void bfin_get_ether_addr(char *addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (ret =3D 0=
; ret < 6; ++ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0addr[ret] =3D otp_mac_p[5 - ret];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf518/boards/tcm-bf518.c b/arch/black=
fin/mach-bf518/boards/tcm-bf518.c
> index f271310..d3c763e 100644
> --- a/arch/blackfin/mach-bf518/boards/tcm-bf518.c
> +++ b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
> @@ -730,9 +730,10 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf527/boards/ad7160eval.c b/arch/blac=
kfin/mach-bf527/boards/ad7160eval.c
> index c8d5d2b..fad7fea 100644
> --- a/arch/blackfin/mach-bf527/boards/ad7160eval.c
> +++ b/arch/blackfin/mach-bf527/boards/ad7160eval.c
> @@ -846,7 +846,7 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the MAC is stored in OTP memory page 0x=
DF */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ret;
> @@ -859,5 +859,6 @@ void bfin_get_ether_addr(char *addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (ret =3D 0=
; ret < 6; ++ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0addr[ret] =3D otp_mac_p[5 - ret];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf527/boards/cm_bf527.c b/arch/blackf=
in/mach-bf527/boards/cm_bf527.c
> index 7330607..5fb09ad 100644
> --- a/arch/blackfin/mach-bf527/boards/cm_bf527.c
> +++ b/arch/blackfin/mach-bf527/boards/cm_bf527.c
> @@ -983,9 +983,10 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf527/boards/ezbrd.c b/arch/blackfin/=
mach-bf527/boards/ezbrd.c
> index db3ecfc..17c6a24 100644
> --- a/arch/blackfin/mach-bf527/boards/ezbrd.c
> +++ b/arch/blackfin/mach-bf527/boards/ezbrd.c
> @@ -870,7 +870,7 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the MAC is stored in OTP memory page 0x=
DF */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ret;
> @@ -883,5 +883,6 @@ void bfin_get_ether_addr(char *addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (ret =3D 0=
; ret < 6; ++ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0addr[ret] =3D otp_mac_p[5 - ret];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/=
mach-bf527/boards/ezkit.c
> index dfdd8e6..89b0f6c 100644
> --- a/arch/blackfin/mach-bf527/boards/ezkit.c
> +++ b/arch/blackfin/mach-bf527/boards/ezkit.c
> @@ -1311,7 +1311,7 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the MAC is stored in OTP memory page 0x=
DF */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ret;
> @@ -1324,5 +1324,6 @@ void bfin_get_ether_addr(char *addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (ret =3D 0=
; ret < 6; ++ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0addr[ret] =3D otp_mac_p[5 - ret];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf527/boards/tll6527m.c b/arch/blackf=
in/mach-bf527/boards/tll6527m.c
> index 360e97f..d192c0a 100644
> --- a/arch/blackfin/mach-bf527/boards/tll6527m.c
> +++ b/arch/blackfin/mach-bf527/boards/tll6527m.c
> @@ -931,7 +931,7 @@ void native_machine_restart(char *cmd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bfin_reset_boo=
t_spi_cs(P_DEFAULT_BOOT_SPI_CS);
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* the MAC is stored in OTP memory page 0x=
DF */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 ret;
> @@ -945,5 +945,6 @@ void bfin_get_ether_addr(char *addr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (ret =3D 0=
; ret < 6; ++ret)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0addr[ret] =3D otp_mac_p[5 - ret];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/cm_bf537e.c b/arch/black=
fin/mach-bf537/boards/cm_bf537e.c
> index 0d4a2f6..618fd7d 100644
> --- a/arch/blackfin/mach-bf537/boards/cm_bf537e.c
> +++ b/arch/blackfin/mach-bf537/boards/cm_bf537e.c
> @@ -813,9 +813,10 @@ void __init native_machine_early_platform_add_de=
vices(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ARRAY_SIZE(cm_=
bf537e_early_devices));
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/cm_bf537u.c b/arch/black=
fin/mach-bf537/boards/cm_bf537u.c
> index f553698..48a7a23 100644
> --- a/arch/blackfin/mach-bf537/boards/cm_bf537u.c
> +++ b/arch/blackfin/mach-bf537/boards/cm_bf537u.c
> @@ -790,9 +790,10 @@ void __init native_machine_early_platform_add_de=
vices(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ARRAY_SIZE(cm_=
bf537u_early_devices));
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/dnp5370.c b/arch/blackfi=
n/mach-bf537/boards/dnp5370.c
> index 11dadeb..6f77bf7 100644
> --- a/arch/blackfin/mach-bf537/boards/dnp5370.c
> +++ b/arch/blackfin/mach-bf537/boards/dnp5370.c
> @@ -399,9 +399,10 @@ arch_initcall(dnp5370_init);
> =C2=A0/*
> =C2=A0* Currently the MAC address is saved in Flash by U-Boot
> =C2=A0*/
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*(u32 *)(&(addr[0])) =3D bfin_read32(FLASH=
_MAC);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*(u16 *)(&(addr[4])) =3D bfin_read16(FLASH=
_MAC + 4);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/pnav10.c b/arch/blackfin=
/mach-bf537/boards/pnav10.c
> index 6fd8470..2a9cd61 100644
> --- a/arch/blackfin/mach-bf537/boards/pnav10.c
> +++ b/arch/blackfin/mach-bf537/boards/pnav10.c
> @@ -535,9 +535,10 @@ void __init native_machine_early_platform_add_de=
vices(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ARRAY_SIZE(sta=
mp_early_devices));
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/stamp.c b/arch/blackfin/=
mach-bf537/boards/stamp.c
> index 2221173..0b80725 100644
> --- a/arch/blackfin/mach-bf537/boards/stamp.c
> +++ b/arch/blackfin/mach-bf537/boards/stamp.c
> @@ -2993,9 +2993,10 @@ void native_machine_restart(char *cmd)
> =C2=A0* Currently the MAC address is saved in Flash by U-Boot
> =C2=A0*/
> =C2=A0#define FLASH_MAC =C2=A0 =C2=A0 =C2=A00x203f0000
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*(u32 *)(&(addr[0])) =3D bfin_read32(FLASH=
_MAC);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*(u16 *)(&(addr[4])) =3D bfin_read16(FLASH=
_MAC + 4);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/arch/blackfin/mach-bf537/boards/tcm_bf537.c b/arch/black=
fin/mach-bf537/boards/tcm_bf537.c
> index 9885176..02eb9d0 100644
> --- a/arch/blackfin/mach-bf537/boards/tcm_bf537.c
> +++ b/arch/blackfin/mach-bf537/boards/tcm_bf537.c
> @@ -780,9 +780,10 @@ void __init native_machine_early_platform_add_de=
vices(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ARRAY_SIZE(cm_=
bf537_early_devices));
> =C2=A0}
>
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0random_ether_addr(addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNING "%s:%s: Setting Ethern=
et MAC to a random one\n", __FILE__, __func__);
> + =C2=A0 =C2=A0 =C2=A0 return 1;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(bfin_get_ether_addr);
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethern=
et/adi/bfin_mac.c
> index d812a10..064a3a6 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -621,6 +621,8 @@ static int bfin_mac_set_mac_address(struct net_de=
vice *dev, void *p)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (netif_running(dev))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EBUSY;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcpy(dev->dev_addr, addr->sa_data, dev->=
addr_len);
> + =C2=A0 =C2=A0 =C2=A0 if (dev->addr_assign_type & NET_ADDR_RANDOM)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev->addr_assign_t=
ype ^=3D NET_ADDR_RANDOM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0setup_mac_addr(dev->dev_addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
> @@ -1496,12 +1498,14 @@ static int __devinit bfin_mac_probe(struct pl=
atform_device *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Grab the MAC from the board somehow
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * this is done in the arch/blackfin/mach-=
bfxxx/boards/eth_mac.c
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (!is_valid_ether_addr(ndev->dev_addr))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bfin_get_ether_add=
r(ndev->dev_addr);
> + =C2=A0 =C2=A0 =C2=A0 if (!is_valid_ether_addr(ndev->dev_addr)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (bfin_get_ether=
_addr(ndev->dev_addr))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 ndev->addr_assign_type |=3D NET_ADDR_RANDOM;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If still not valid, get a random one */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!is_valid_ether_addr(ndev->dev_addr))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 random_ether_addr(=
ndev->dev_addr);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_hw_addr_random=
(ndev, ndev->dev_addr);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0setup_mac_addr(ndev->dev_addr);
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethern=
et/adi/bfin_mac.h
> index f8559ac..960905c 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.h
> +++ b/drivers/net/ethernet/adi/bfin_mac.h
> @@ -101,6 +101,6 @@ struct bfin_mac_local {
> =C2=A0#endif
> =C2=A0};
>
> -extern void bfin_get_ether_addr(char *addr);
> +extern int bfin_get_ether_addr(char *addr);
>
> =C2=A0#endif
> --
> 1.7.7.3
>

--=20
Thanks,
--Bob
