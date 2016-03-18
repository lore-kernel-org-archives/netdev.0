From: Tomeu Vizoso <tomeu@tomeuvizoso.net>
Subject: Re: [PATCH (net-next.git)] stmmac: fix TX normal DESC
Date: Fri, 18 Mar 2016 15:07:26 +0100
Message-ID: <CAAObsKAB81s-2NS3ZGQsJ7RDnKAhgQApmD2Jnk1nNfzucMvTpw@mail.gmail.com>
References: <1458123709-19692-1-git-send-email-peppe.cavallaro@st.com> <1458123709-19692-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>,
	=?UTF-8?Q?Frank_Sch=C3=A4fer?= <fschaefer.oss@googlemail.com>,
	Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, preid@electromag.com.au,
	Fabrice GASNIER <fabrice.gasnier@st.com>,
	Alexandre TORGUE <alexandre.torgue@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36797 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775AbcCROHs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 10:07:48 -0400
Received: by mail-wm0-f48.google.com with SMTP id l124so32613398wmf.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 07:07:47 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by smtp.gmail.com with ESMTPSA id av3sm12396252wjc.44.2016.03.18.07.07.46
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 07:07:46 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so70585596wmp.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 07:07:46 -0700 (PDT)
In-Reply-To: <1458123709-19692-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16 March 2016 at 11:21, Giuseppe Cavallaro <peppe.cavallaro@st.com> =
wrote:
> This patch fixs a regression raised when test on chips that use
> the normal descriptor layout. In fact, no len bits were set for
> the TDES1 and no OWN bit inside the TDES0.
>
> Signed-off-by: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Tested-by: Andreas F=C3=A4rber <afaerber@suse.de>
> Cc: Fabrice Gasnier <fabrice.gasnier@st.com>

Hi,

with this patch, I have eth working reliably on the Rock2 again.

Tested-by: Tomeu Vizoso <tomeu.vizoso@collabora.com>

Thanks,

Tomeu

> ---
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c |   16 ++++++++-----=
---
>  1 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/driver=
s/net/ethernet/stmicro/stmmac/norm_desc.c
> index e13228f..011386f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -199,11 +199,6 @@ static void ndesc_prepare_tx_desc(struct dma_des=
c *p, int is_fs, int len,
>  {
>         unsigned int tdes1 =3D p->des1;
>
> -       if (mode =3D=3D STMMAC_CHAIN_MODE)
> -               norm_set_tx_desc_len_on_chain(p, len);
> -       else
> -               norm_set_tx_desc_len_on_ring(p, len);
> -
>         if (is_fs)
>                 tdes1 |=3D TDES1_FIRST_SEGMENT;
>         else
> @@ -217,10 +212,15 @@ static void ndesc_prepare_tx_desc(struct dma_de=
sc *p, int is_fs, int len,
>         if (ls)
>                 tdes1 |=3D TDES1_LAST_SEGMENT;
>
> -       if (tx_own)
> -               tdes1 |=3D TDES0_OWN;
> -
>         p->des1 =3D tdes1;
> +
> +       if (mode =3D=3D STMMAC_CHAIN_MODE)
> +               norm_set_tx_desc_len_on_chain(p, len);
> +       else
> +               norm_set_tx_desc_len_on_ring(p, len);
> +
> +       if (tx_own)
> +               p->des0 |=3D TDES0_OWN;
>  }
>
>  static void ndesc_set_tx_ic(struct dma_desc *p)
> --
> 1.7.4.4
>
