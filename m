From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: pull-request: wireless-drivers 2016-02-18
Date: Mon, 29 Feb 2016 09:35:21 +0100
Message-ID: <CAMuHMdWVJ+rC1w_-mHdWhDJ_q++W_hp-Fg4JTjSSSseS1aDd5Q@mail.gmail.com>
References: <87mvqyqbqp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87mvqyqbqp.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 4:28 PM, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrot=
e:
> Hi Dave,
>
> I have some important fixes I would like to get 4.5 still, more info =
in
> the signed tag. Please let me know if you have problems.
>
> Kalle
>
> The following changes since commit f9ead9beef3f44be0db4b542a8c2ce698f=
b1530e:
>
>   Merge tag 'iwlwifi-for-kalle-2016-01-26_2' of https://git.kernel.or=
g/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-01-27 14:19:18 +=
0200)
>
> are available in the git repository at:
>
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-driver=
s.git tags/wireless-drivers-for-davem-2016-02-18
>
> for you to fetch changes up to c699404db182836498bd9d9a36ef044de2cab4=
fd:
>
>   Merge tag 'iwlwifi-for-kalle-2016-02-15' of https://git.kernel.org/=
pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-02-16 17:58:30 +02=
00)
>
> ----------------------------------------------------------------
>
> rtlwifi
>
> * fix broken VHT (802.11ac) support, reported by Linus

That's commit d76d65fd26951498144029c24852c4d54ee512d9

drivers/net/wireless/realtek/rtlwifi/rc.c: In function
=E2=80=98_rtl_rc_rate_set_series=E2=80=99:
drivers/net/wireless/realtek/rtlwifi/rc.c:144: warning: comparison is
always false due to limited range of data type

                if (sta && sta->vht_cap.vht_supported &&
                    (wireless_mode =3D=3D WIRELESS_MODE_AC_5G ||
                     wireless_mode =3D=3D WIRELESS_MODE_AC_24G ||
                     wireless_mode =3D=3D WIRELESS_MODE_AC_ONLY))
                        rate->flags |=3D IEEE80211_TX_RC_VHT_MCS;

u8 wireless_mode =3D 0;

enum wireless_mode {
        ...
        WIRELESS_MODE_AC_ONLY =3D 0x100,

How is that supposed to work?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
