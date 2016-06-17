From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] brcmfmac: use const char * for interface name in
 brcmf_add_if
Date: Fri, 17 Jun 2016 04:23:14 -0700
Message-ID: <1466162594.19647.107.camel@perches.com>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
	 <1466160530-32626-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466160530-32626-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-06-17 at 12:48 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:
> This function can work just fine with const pointer, it only calls
> alloc_netdev which take const as well. Moreover it makes this functio=
n
> more flexible as some cfg80211 callback may provide const char * as
> well, e.g. add_virtual_intf. This will be needed for more advanced
> interface management.
[]
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c =
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
[]
> @@ -638,7 +638,7 @@ fail:
> =C2=A0}
> =C2=A0
> =C2=A0struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscf=
gidx, s32 ifidx,
> -			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool is_p2pdev, char *name, u=
8 *mac_addr)
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool is_p2pdev, const char *n=
ame, u8 *mac_addr)

Looks like mac_addr should be const too

> =C2=A0{
> =C2=A0	struct brcmf_if *ifp;
> =C2=A0	struct net_device *ndev;
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h =
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
[]
> @@ -215,7 +215,7 @@ char *brcmf_ifname(struct brcmf_if *ifp);
> =C2=A0struct brcmf_if *brcmf_get_ifp(struct brcmf_pub *drvr, int ifid=
x);
> =C2=A0int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
> =C2=A0struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscf=
gidx, s32 ifidx,
> -			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool is_p2pdev, char *name, u=
8 *mac_addr);
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0bool is_p2pdev, const char *n=
ame, u8 *mac_addr);
> =C2=A0void brcmf_remove_interface(struct brcmf_if *ifp, bool rtnl_loc=
ked);
> =C2=A0void brcmf_txflowblock_if(struct brcmf_if *ifp,
> =C2=A0			=C2=A0=C2=A0enum brcmf_netif_stop_reason reason, bool state)=
;
