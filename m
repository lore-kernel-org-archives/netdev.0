From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers 2016-02-18
Date: Fri, 04 Mar 2016 17:29:25 +0200
Message-ID: <87y49yw9be.fsf@kamboji.qca.qualcomm.com>
References: <87mvqyqbqp.fsf@kamboji.qca.qualcomm.com>
	<CAMuHMdWVJ+rC1w_-mHdWhDJ_q++W_hp-Fg4JTjSSSseS1aDd5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Larry.Finger@lwfinger.net
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41043 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbcCDP3d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 10:29:33 -0500
In-Reply-To: <CAMuHMdWVJ+rC1w_-mHdWhDJ_q++W_hp-Fg4JTjSSSseS1aDd5Q@mail.gmail.com>
	(Geert Uytterhoeven's message of "Mon, 29 Feb 2016 09:35:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Adding Larry)

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> On Thu, Feb 18, 2016 at 4:28 PM, Kalle Valo <kvalo@codeaurora.org> wr=
ote:
>
>> rtlwifi
>>
>> * fix broken VHT (802.11ac) support, reported by Linus
>
> That's commit d76d65fd26951498144029c24852c4d54ee512d9
>
> drivers/net/wireless/realtek/rtlwifi/rc.c: In function
> =E2=80=98_rtl_rc_rate_set_series=E2=80=99:
> drivers/net/wireless/realtek/rtlwifi/rc.c:144: warning: comparison is
> always false due to limited range of data type
>
>                 if (sta && sta->vht_cap.vht_supported &&
>                     (wireless_mode =3D=3D WIRELESS_MODE_AC_5G ||
>                      wireless_mode =3D=3D WIRELESS_MODE_AC_24G ||
>                      wireless_mode =3D=3D WIRELESS_MODE_AC_ONLY))
>                         rate->flags |=3D IEEE80211_TX_RC_VHT_MCS;
>
> u8 wireless_mode =3D 0;
>
> enum wireless_mode {
>         ...
>         WIRELESS_MODE_AC_ONLY =3D 0x100,
>
> How is that supposed to work?

I have no idea what could be the difference, for example, between AC_5G
and AC_ONLY. Maybe AC_ONLY mode is not really used in normal setups and
that's why the bug doesn't break anything? Larry, do you know?

Anyway, Larry has a patch for this but I'm planning to send it to 4.6 a=
s
I didn't think it as that urgent:

rtlwifi: Fix size of wireless mode variable

https://patchwork.kernel.org/patch/8425191/

--=20
Kalle Valo
