From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: pull-request: wireless-drivers 2016-02-18
Date: Fri, 4 Mar 2016 11:14:09 -0600
Message-ID: <56D9C261.6000900@lwfinger.net>
References: <87mvqyqbqp.fsf@kamboji.qca.qualcomm.com>
 <CAMuHMdWVJ+rC1w_-mHdWhDJ_q++W_hp-Fg4JTjSSSseS1aDd5Q@mail.gmail.com>
 <87y49yw9be.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35810 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcCDROM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 12:14:12 -0500
In-Reply-To: <87y49yw9be.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2016 09:29 AM, Kalle Valo wrote:
> (Adding Larry)
>
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>
>> On Thu, Feb 18, 2016 at 4:28 PM, Kalle Valo <kvalo@codeaurora.org> w=
rote:
>>
>>> rtlwifi
>>>
>>> * fix broken VHT (802.11ac) support, reported by Linus
>>
>> That's commit d76d65fd26951498144029c24852c4d54ee512d9
>>
>> drivers/net/wireless/realtek/rtlwifi/rc.c: In function
>> =E2=80=98_rtl_rc_rate_set_series=E2=80=99:
>> drivers/net/wireless/realtek/rtlwifi/rc.c:144: warning: comparison i=
s
>> always false due to limited range of data type
>>
>>                  if (sta && sta->vht_cap.vht_supported &&
>>                      (wireless_mode =3D=3D WIRELESS_MODE_AC_5G ||
>>                       wireless_mode =3D=3D WIRELESS_MODE_AC_24G ||
>>                       wireless_mode =3D=3D WIRELESS_MODE_AC_ONLY))
>>                          rate->flags |=3D IEEE80211_TX_RC_VHT_MCS;
>>
>> u8 wireless_mode =3D 0;
>>
>> enum wireless_mode {
>>          ...
>>          WIRELESS_MODE_AC_ONLY =3D 0x100,
>>
>> How is that supposed to work?
>
> I have no idea what could be the difference, for example, between AC_=
5G
> and AC_ONLY. Maybe AC_ONLY mode is not really used in normal setups a=
nd
> that's why the bug doesn't break anything? Larry, do you know?
>
> Anyway, Larry has a patch for this but I'm planning to send it to 4.6=
 as
> I didn't think it as that urgent:
>
> rtlwifi: Fix size of wireless mode variable
>
> https://patchwork.kernel.org/patch/8425191/

That WIRELESS_MODE_AC_ONLY mode is part of a recent commit to a repo th=
at=20
Realtek and I use as a place for their most recent changes. As I do not=
 have,=20
nor want, an NDA with them, I could only speculate about their reasons =
for such=20
a mode. I included it because I was touching that portion of the code.=20
Unfortunately, I did not catch the associated change in the variable si=
ze.

Saving the second patch for 4.6 is the correct action.

Larry
