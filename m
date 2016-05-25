From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: fix setting AP channel with new firmwares
Date: Wed, 25 May 2016 23:08:05 +0200
Message-ID: <57461435.9080708@broadcom.com>
References: <1464080979-12150-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464080979-12150-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 24-05-16 11:09, Rafa=C5=82 Mi=C5=82ecki wrote:
> Firmware for new chipsets is based on a new major version of code
> internally maintained at Broadcom. E.g. brcmfmac4366b-pcie.bin (used =
for
> BCM4366B1) is based on 10.10.69.3309 while brcmfmac43602-pcie.ap.bin =
was
> based on 7.35.177.56.
>=20
> Currently setting AP 5 GHz channel doesn't work reliably with BCM4366=
B1.
> When setting e.g. 36 control channel with VHT80 (center channel 42)
> firmware may randomly pick one of:
> 1) 52 control channel with 58 as center one
> 2) 100 control channel with 106 as center one
> 3) 116 control channel with 122 as center one
> 4) 149 control channel with 155 as center one
>=20
> It seems new firmwares require setting AP mode (BRCMF_C_SET_AP) befor=
e
> specifying a channel. Changing an order of firmware calls fixes the
> problem.
>=20
> This fix was verified with BCM4366B1 and tested for regressions on
> BCM43602. It's unclear if it's needed (or correct at all) for P2P
> interfaces so it leaves this code unaffected.

In doing so the code reads a bit awkward so if P2P-GO works with the
changed order that would be preferable.

> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>  .../net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c  | 16 ++++++=
++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
