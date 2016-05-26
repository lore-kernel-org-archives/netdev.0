From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH V3] brcmfmac: print error if p2p_ifadd firmware command
 fails
Date: Thu, 26 May 2016 10:07:06 +0200
Message-ID: <434b808f-0433-2b01-29b9-24331a773e7c@broadcom.com>
References: <1464123910-8281-1-git-send-email-zajec5@gmail.com>
 <1464216299-25232-1-git-send-email-zajec5@gmail.com>
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
In-Reply-To: <1464216299-25232-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26-5-2016 0:44, Rafa=C5=82 Mi=C5=82ecki wrote:
> This is helpful for debugging, without this all I was getting from "i=
w"
> command on device with BCM43602 was:
>> command failed: Too many open files in system (-23)
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
> V2: s/in/if/ in commit message
> V3: Add one more error message as suggested by Arend
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b=
/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> index 1652a48..bc26aec 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
> @@ -2031,7 +2031,7 @@ static int brcmf_p2p_request_p2p_if(struct brcm=
f_p2p_info *p2p,
>  	err =3D brcmf_fil_iovar_data_set(ifp, "p2p_ifadd", &if_request,
>  				       sizeof(if_request));
>  	if (err)
> -		return err;
> +		brcmf_err("p2p_ifadd failed %d\n", err);
> =20
>  	return err;
>  }
> @@ -2185,6 +2185,7 @@ struct wireless_dev *brcmf_p2p_add_vif(struct w=
iphy *wiphy, const char *name,
>  	err =3D brcmf_p2p_request_p2p_if(&cfg->p2p, ifp, cfg->p2p.int_addr,
>  				       iftype);
>  	if (err) {
> +		brcmf_err("Failed to request P2P virtual interface %s\n", name);
>  		brcmf_cfg80211_arm_vif_event(cfg, NULL);
>  		goto fail;
>  	}

Not exactly what I meant. I meant instead of and the function I would
like the error message in is brcmf_cfg80211_add_iface() so you also get
an error message when AP interface creation fails.

Regards,
Arend
