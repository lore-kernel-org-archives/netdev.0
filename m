From: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 1/1 linux-next] ath5k: use swap() in
 ath5k_hw_get_median_noise_floor()
Date: Wed, 10 Jun 2015 21:59:38 +0200 (CEST)
Message-ID: <1121998377.24127.1433966378845.open-xchange@webmail.nmp.proximus.be>
References: <1433954015-24872-1-git-send-email-fabf@skynet.be> <1433965966.32331.25.camel@perches.com>
Reply-To: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433965966.32331.25.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> On 10 June 2015 at 21:52 Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
>
>
> On Wed, 2015-06-10 at 18:33 +0200, Fabian Frederick wrote:
> > Use kernel.h macro definition.
> >
> > Thanks to Julia Lawall for Coccinelle scripting support.
> []
> > diff --git a/drivers/net/wireless/ath/ath5k/phy.c
> > b/drivers/net/wireless/ath/ath5k/phy.c
> []
> > @@ -1566,17 +1566,13 @@ static s16
> >=C2=A0 ath5k_hw_get_median_noise_floor(struct ath5k_hw *ah)
> >=C2=A0 {
> >=C2=A0 =C2=A0 =C2=A0s16 sort[ATH5K_NF_CAL_HIST_MAX];
> > -=C2=A0 =C2=A0s16 tmp;
> >=C2=A0 =C2=A0 =C2=A0int i, j;
> >=C2=A0
> >=C2=A0 =C2=A0 =C2=A0memcpy(sort, ah->ah_nfcal_hist.nfval, sizeof(sor=
t));
> >=C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < ATH5K_NF_CAL_HIST_MAX - 1; i++=
) {
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (j =3D 1; j < AT=
H5K_NF_CAL_HIST_MAX - i; j++) {
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0if (sort[j] > sort[j - 1]) {
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tmp =3D sort[j];
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sort[j] =3D sort[j - 1];
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sort[j - 1] =3D tmp;
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0}
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0if (sort[j] > sort[j - 1])
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0swap(sort[j], sort[j]);
>
> swap(a, a) doesn't look useful.
Thanks a lot Joe, I'll fix this one :)

Regards,
=46abian
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
