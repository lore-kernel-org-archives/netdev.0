From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: rework function picking free BSS index
Date: Thu,  9 Jun 2016 16:17:32 +0000 (UTC)
Message-ID: <20160609161732.90E20613F6@smtp.codeaurora.org>
References: <1464219876-13776-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464219876-13776-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki wrote:
> The old implementation was overcomplicated and slightly bugged in som=
e
> corner cases.
>=20
> Consider following state of BSS-es (limited to 6 for simplification):
> drvr->iflist[0]: { bsscfgidx:0, ndev->name:wlan1, }
> drvr->iflist[1]:  (null)
> drvr->iflist[2]: { bsscfgidx:2, ndev->name:wlan1-1, }
> drvr->iflist[3]: { bsscfgidx:3, ndev->name:wlan1-2, }
> drvr->iflist[4]:  (null)
> drvr->iflist[5]:  (null)
> In such case the next AP interface should bsscfgidx 4 (we don't use 1=
 as
> it's reserved for P2P).
>=20
> With old code the loop iterations were following:
> [ifidx =3D 0] [bsscfgidx =3D 2] [highest =3D 2]
> [ifidx =3D 1] [bsscfgidx =3D 2] [highest =3D 2] available =3D true
> [ifidx =3D 2] [bsscfgidx =3D 2] [highest =3D 2] bsscfgidx =3D highest=
 + 1
> [ifidx =3D 3] [bsscfgidx =3D 3] [highest =3D 2] bsscfgidx =3D highest=
 + 1
> [ifidx =3D 4] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
> [ifidx =3D 5] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
> There were 2 obvious problems:
> 1) Having empty BSS at index 1 was resulting in available being alway=
s
>    set to true, even if we would run out of BSS-es.
> 2) Calculated bsscfgidx was invalid (3 instead of 4) resulting in dri=
ver
>    not being able to create the 4th AP interface.
>=20
> New code is simpler, placed in file where it's really used, handles
> running out of free BSS-es and allows using 4 interfaces at the same
> time. It also looks for the first free BSS instead of one after the l=
ast
> in use. It works well with current driver (which doesn't allow deleti=
ng
> interfaces) and should be future proof (if we ever allow deleting).
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

d02fb8f14b2d brcmfmac: rework function picking free BSS index

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9136421/
