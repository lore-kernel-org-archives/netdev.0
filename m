From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath10k: spectral: Simplify error checking
Date: Fri, 13 Oct 2017 12:28:50 +0000
Message-ID: <87fuannse6.fsf@kamboji.qca.qualcomm.com>
References: <1507491026-28690-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christos Gkekas <chris.gekas@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507491026-28690-1-git-send-email-chris.gekas@gmail.com>
        (Christos Gkekas's message of "Sun, 8 Oct 2017 20:30:26 +0100")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christos Gkekas <chris.gekas@gmail.com> writes:

> Variable val is unsigned so checking whether it is less than zero is
> redundant.
>
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
> ---
>  drivers/net/wireless/ath/ath10k/spectral.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/spectral.c b/drivers/net/wir=
eless/ath/ath10k/spectral.c
> index dd9cc09..1867937 100644
> --- a/drivers/net/wireless/ath/ath10k/spectral.c
> +++ b/drivers/net/wireless/ath/ath10k/spectral.c
> @@ -403,10 +403,7 @@ static ssize_t write_file_spectral_count(struct file=
 *file,
>  		return -EFAULT;
> =20
>  	buf[len] =3D '\0';
> -	if (kstrtoul(buf, 0, &val))
> -		return -EINVAL;
> -
> -	if (val < 0 || val > 255)
> +	if (kstrtoul(buf, 0, &val) || val > 255)
>  		return -EINVAL;

Removing the check for negative is correct but I don't think you are
simplifying anything, on the contrary it's harder to read. Please keep
the two if statements separate.

--=20
Kalle Valo=
