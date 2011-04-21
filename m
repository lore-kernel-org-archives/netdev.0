From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Thu, 21 Apr 2011 10:31:36 +0200
Message-ID: <1303374696.3685.14.camel@edumazet-laptop>
References: <1303322263-18991-10-git-send-email-mcarlson@broadcom.com>
	 <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 20 avril 2011 =C3=A0 23:39 -0700, Joe Perches a =C3=A9crit =
:
> Using a bitmap instead of separate u32 flags allows a consistent, sim=
pler
> and more extensible mechanism to determine capabilities.
>=20
> Convert bitfields to indexes.
> Add tg3_flag, tg3_flag_clear and tg3_flag_set
> Convert the flag & bitmask tests.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/tg3.c | 1262 ++++++++++++++++++++++++++-----------------=
----------
>  drivers/net/tg3.h |  164 ++++----
>  2 files changed, 696 insertions(+), 730 deletions(-)


Use an enum ?

Why first value is 1 and not 0 ?

> +#define TG3_FLAG_TAGGED_STATUS		1
> +#define TG3_FLAG_TXD_MBOX_HWBUG		2
> +#define TG3_FLAG_USE_LINKCHG_REG	3
> +#define TG3_FLAG_ERROR_PROCESSED	4
> +#define TG3_FLAG_ENABLE_ASF		5
> +#define TG3_FLAG_ASPM_WORKAROUND	6
> +#define TG3_FLAG_POLL_SERDES		7
> +#define TG3_FLAG_MBOX_WRITE_REORDER	8
> +#define TG3_FLAG_PCIX_TARGET_HWBUG	9
> +#define TG3_FLAG_WOL_SPEED_100MB	10
> +#define TG3_FLAG_WOL_ENABLE		11
> +#define TG3_FLAG_EEPROM_WRITE_PROT	12
> +#define TG3_FLAG_NVRAM			13
> +#define TG3_FLAG_NVRAM_BUFFERED		14
> +#define TG3_FLAG_SUPPORT_MSI		15
> +#define TG3_FLAG_SUPPORT_MSIX		16
> +#define TG3_FLAG_PCIX_MODE		17
> +#define TG3_FLAG_PCI_HIGH_SPEED		18
> +#define TG3_FLAG_PCI_32BIT		19
> +#define TG3_FLAG_SRAM_USE_CONFIG	20
> +#define TG3_FLAG_TX_RECOVERY_PENDING	21
> +#define TG3_FLAG_WOL_CAP		22
> +#define TG3_FLAG_JUMBO_RING_ENABLE	23
> +#define TG3_FLAG_PAUSE_AUTONEG		24
> +#define TG3_FLAG_CPMU_PRESENT		25
> +#define TG3_FLAG_40BIT_DMA_BUG		26
> +#define TG3_FLAG_BROKEN_CHECKSUMS	27
> +#define TG3_FLAG_JUMBO_CAPABLE		28
> +#define TG3_FLAG_CHIP_RESETTING		29
> +#define TG3_FLAG_INIT_COMPLETE		30
> +#define TG3_FLAG_RESTART_TIMER		31
> +#define TG3_FLAG_TSO_BUG		32
> +#define TG3_FLAG_IS_5788		33
> +#define TG3_FLAG_MAX_RXPEND_64		34
> +#define TG3_FLAG_TSO_CAPABLE		35
> +#define TG3_FLAG_PCI_EXPRESS		36
> +#define TG3_FLAG_ASF_NEW_HANDSHAKE	37
> +#define TG3_FLAG_HW_AUTONEG		38
> +#define TG3_FLAG_IS_NIC			39
> +#define TG3_FLAG_FLASH			40
> +#define TG3_FLAG_HW_TSO_1		41
> +#define TG3_FLAG_5705_PLUS		42
> +#define TG3_FLAG_5750_PLUS		43
> +#define TG3_FLAG_HW_TSO_3		44
> +#define TG3_FLAG_USING_MSI		45
> +#define TG3_FLAG_USING_MSIX		46
> +#define TG3_FLAG_ICH_WORKAROUND		47
> +#define TG3_FLAG_5780_CLASS		48
> +#define TG3_FLAG_HW_TSO_2		49
> +#define TG3_FLAG_1SHOT_MSI		50
> +#define TG3_FLAG_NO_FWARE_REPORTED	51
> +#define TG3_FLAG_NO_NVRAM_ADDR_TRANS	52
> +#define TG3_FLAG_ENABLE_APE		53
> +#define TG3_FLAG_PROTECTED_NVRAM	54
> +#define TG3_FLAG_5701_DMA_BUG		55
> +#define TG3_FLAG_USE_PHYLIB		56
> +#define TG3_FLAG_MDIOBUS_INITED		57
> +#define TG3_FLAG_LRG_PROD_RING_CAP	58
> +#define TG3_FLAG_RGMII_INBAND_DISABLE	59
> +#define TG3_FLAG_RGMII_EXT_IBND_RX_EN	60
> +#define TG3_FLAG_RGMII_EXT_IBND_TX_EN	61
> +#define TG3_FLAG_CLKREQ_BUG		62
> +#define TG3_FLAG_5755_PLUS		63
> +#define TG3_FLAG_NO_NVRAM		64
> +#define TG3_FLAG_ENABLE_RSS		65
> +#define TG3_FLAG_ENABLE_TSS		66
> +#define TG3_FLAG_4G_DMA_BNDRY_BUG	67
> +#define TG3_FLAG_40BIT_DMA_LIMIT_BUG	68
> +#define TG3_FLAG_SHORT_DMA_BUG		69
> +#define TG3_FLAG_USE_JUMBO_BDFLAG	70
> +#define TG3_FLAG_L1PLLPD_EN		71
> +#define TG3_FLAG_57765_PLUS		72
> +#define TG3_FLAG_APE_HAS_NCSI		73
> +#define TG3_FLAG_5717_PLUS		74
> +#define TG3_FLAGS			74	/* Set to number of flags */
> +
>  struct tg3 {
>  	/* begin "general, frequently-used members" cacheline section */
> =20
> @@ -2838,7 +2914,7 @@ struct tg3 {
>  	/* SMP locking strategy:
>  	 *
>  	 * lock: Held during reset, PHY access, timer, and when
> -	 *       updating tg3_flags and tg3_flags2.
> +	 *       updating tg3_flags.
>  	 *
>  	 * netif_tx_lock: Held during tg3_start_xmit. tg3_tx holds
>  	 *                netif_tx_lock when it needs to call
> @@ -2895,95 +2971,13 @@ struct tg3 {
>  	struct tg3_ethtool_stats	estats;
>  	struct tg3_ethtool_stats	estats_prev;
> =20
> +	DECLARE_BITMAP(tg3_flags, TG3_FLAGS);
> +

Also you need to make TG3_FLAGS be (last_flag_value + 1) or you could
miss one long in bitmap. (Not now, but later when new flags are added
and reach a multiple of BITS_PER_BYTE * sizeof(long)
