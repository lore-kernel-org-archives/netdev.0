From: "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath10k: fix memory leak on caldata on error exit path
Date: Fri, 2 Sep 2016 15:45:09 +0000
Message-ID: <87r392z4ox.fsf@kamboji.qca.qualcomm.com>
References: <1471268785-11576-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471268785-11576-1-git-send-email-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
        (Colin King's message of "Mon, 15 Aug 2016 14:46:25 +0100")
Content-Language: en-US
Content-ID: <B6808281641328458EF5B7FC91C3B26E-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> caldata is not being free'd on the error exit path, causing
> a memory leak. kfree it to fix the leak.
>
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/ath/ath10k/pci.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless=
/ath/ath10k/pci.c
> index 9a22c47..886337c 100644
> --- a/drivers/net/wireless/ath/ath10k/pci.c
> +++ b/drivers/net/wireless/ath/ath10k/pci.c
> @@ -2725,6 +2725,7 @@ static int ath10k_pci_hif_fetch_cal_eeprom(struct a=
th10k *ar, void **data,
>  	return 0;
> =20
>  err_free:
> +	kfree(caldata);
>  	kfree(data);
> =20
>  	return -EINVAL;

I don't think we should free data at all:

static int ath10k_download_cal_eeprom(struct ath10k *ar)
{
	size_t data_len;
	void *data =3D NULL;
	int ret;

	ret =3D ath10k_hif_fetch_cal_eeprom(ar, &data, &data_len);

Instead we should free only caldata, right?

--=20
Kalle Valo=
