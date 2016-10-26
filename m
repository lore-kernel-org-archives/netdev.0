From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 19/28] brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap
Date: Wed, 26 Oct 2016 14:11:23 +0300
Message-ID: <87funj5pr8.fsf@kamboji.qca.qualcomm.com>
References: <20161017220342.1627073-1-arnd@arndb.de>
        <20161017221355.1861551-7-arnd@arndb.de>
        <87zilr61ux.fsf@kamboji.qca.qualcomm.com> <3406231.8mt2808XDi@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "Franky \(Zhenhui\) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3406231.8mt2808XDi@wuerfel> (Arnd Bergmann's message of "Wed, 26
        Oct 2016 11:57:23 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:

> On Wednesday, October 26, 2016 9:49:58 AM CEST Kalle Valo wrote:
>> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:
>>=20
>> > A bugfix added a sanity check around the assignment and use of the
>> > 'is_11d' variable, which looks correct to me, but as the function is
>> > rather complex already, this confuses the compiler to the point where
>> > it can no longer figure out if the variable is always initialized
>> > correctly:
>> >
>> > brcm80211/brcmfmac/cfg80211.c: In function =E2=80=98brcmf_cfg80211_sta=
rt_ap=E2=80=99:
>> > brcm80211/brcmfmac/cfg80211.c:4586:10: error: =E2=80=98is_11d=E2=80=99=
 may be used uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>> >
>> > This adds an initialization for the newly introduced case in which
>> > the variable should not really be used, in order to make the warning
>> > go away.
>> >
>> > Fixes: b3589dfe0212 ("brcmfmac: ignore 11d configuration errors")
>> > Cc: Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> > Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> > Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>> > Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>>=20
>> Via which tree are you planning to submit this? Should I take it?
>
> I'd prefer if you can take it and forward it along with your other
> bugfixes. I'll try to take care of the ones that nobody else
> picked up.

Ok, I'll take it. I'm planning to push this to 4.9.

--=20
Kalle Valo
