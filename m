From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH V2] brcmfmac: print error if p2p_ifadd firmware command
 fails
Date: Wed, 25 May 2016 23:05:17 +0200
Message-ID: <5746138D.2090700@broadcom.com>
References: <1464123728-7555-1-git-send-email-zajec5@gmail.com>
 <1464123910-8281-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464123910-8281-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24-05-16 23:05, Rafa=C5=82 Mi=C5=82ecki wrote:
> This is helpful for debugging, without this all I was getting from "i=
w"
> command on device with BCM43602 was:
>> command failed: Too many open files in system (-23)
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
> V2: s/in/if/ in commit message
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b=
/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> index 1652a48..f7b7e29 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> @@ -2031,7 +2031,7 @@ static int brcmf_p2p_request_p2p_if(struct brcm=
f_p2p_info *p2p,
>  	err =3D brcmf_fil_iovar_data_set(ifp, "p2p_ifadd", &if_request,
>  				       sizeof(if_request));
>  	if (err)
> -		return err;
> +		brcmf_err("p2p_ifadd failed %d\n", err);

I would prefer adding a more generic failure message including ifname
and type in brcmf_cfg80211_add_iface() in cfg80211.c.

Regards,
Arend

> =20
>  	return err;
>  }
>=20
