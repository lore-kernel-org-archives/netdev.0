From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] brcmsmac: don't leak kernel memory via printk()
Date: Wed, 10 Dec 2014 11:30:16 +0100
Message-ID: <548820B8.8020407@broadcom.com>
References: <1418204358-8357-1-git-send-email-computersforpeace@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
To: Brian Norris <computersforpeace@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64196 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaLJKaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 05:30:24 -0500
In-Reply-To: <1418204358-8357-1-git-send-email-computersforpeace@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-14 10:39, Brian Norris wrote:
> Debug code prints the fifo name via custom dev_warn() wrappers. The
> fifo_names array is only non-zero when debugging is manually enabled,
> which is all well and good. However, it's *not* good that this array
> uses zero-length arrays in the non-debug case, and so it doesn't
> actually have any memory allocated to it. This means that as far as w=
e
> know, fifo_names[i] actually points to garbage memory.
>=20
> I've seen this in my log:
>=20
> [ 4601.205511] brcmsmac bcma0:1: wl0: brcms_c_d11hdrs_mac80211: =EF=BF=
=BDGeL txop exceeded phylen 137/256 dur 1602/1504
>=20
> So let's give this array space enough to fill it with a NULL byte.
>=20

+ Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Brian Norris <computersforpeace@gmail.com>
> Cc: Brett Rudley <brudley@broadcom.com>
- Cc: Arend van Spriel <arend@broadcom.com>
> Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
> Cc: Hante Meuleman <meuleman@broadcom.com>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: brcm80211-dev-list@broadcom.com
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/wireless/brcm80211/brcmsmac/main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers=
/net/wireless/brcm80211/brcmsmac/main.c
> index 1b474828d5b8..aed0c948dce8 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
> @@ -316,7 +316,7 @@ static const u16 xmtfifo_sz[][NFIFO] =3D {
>  static const char * const fifo_names[] =3D {
>  	"AC_BK", "AC_BE", "AC_VI", "AC_VO", "BCMC", "ATIM" };
>  #else
> -static const char fifo_names[6][0];
> +static const char fifo_names[6][1];
>  #endif
> =20
>  #ifdef DEBUG
>=20
