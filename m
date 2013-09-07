From: David R <david@unsolicited.net>
Subject: Re: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Sat, 07 Sep 2013 18:19:40 +0100
Message-ID: <522B602C.80701@unsolicited.net>
References: <5221C226.9040209@starox.org> <20130901213610.GA25211@electric-eye.fr.zoreil.com> <52245E82.5020004@starox.org> <20130907101546.GA19560@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>,
	netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.unsolicited.net ([173.255.193.191]:53662 "EHLO
	mx1.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3IGRl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 13:41:29 -0400
In-Reply-To: <20130907101546.GA19560@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

You mean this line from the dmesg? :-

[    6.015979] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    6.016285] r8169 0000:02:00.0: irq 73 for MSI/MSI-X
[    6.016549] r8169 0000:02:00.0 eth0: RTL8168f/8111f at
0xffffc9000060e000, 60:a4:4c:2c:ff:a1, XID 08000800 IRQ 73

Cheers
David

On 07/09/13 11:15, Francois Romieu wrote:
> Fr=C3=A9d=C3=A9ric Leroy <fredo@starox.org> :
> [...]
>
> Sorry for the delay. It was a busy week.
>
> Can you give the hack below a try ?
>
> David, could you send me the r8169 XID line from a kernel running on
> the hardware for which I sent you a similar patch back in 2013/04 ?
> You appeared to own a 8168f and it could be a RTL_GIGA_MAC_VER_36.
>
> Thanks.
>
> Hayes, see http://marc.info/?l=3Dlinux-netdev&m=3D137794473416308&w=3D=
1 for
> history. It could be eb2dc35d99028b698cdedba4f5522bc43e576bd2
> ("r8169: RxConfig hack for the 8168evl.") return, with a revenge.
>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ether=
net/realtek/r8169.c
> index 6f87f2c..3397cee 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4231,6 +4231,7 @@ static void rtl_init_rxcfg(struct rtl8169_priva=
te *tp)
>  	case RTL_GIGA_MAC_VER_23:
>  	case RTL_GIGA_MAC_VER_24:
>  	case RTL_GIGA_MAC_VER_34:
> +	case RTL_GIGA_MAC_VER_35:
>  		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
>  		break;
>  	case RTL_GIGA_MAC_VER_40:
