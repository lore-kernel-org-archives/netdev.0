From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 19/28] brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap
Date: Wed, 26 Oct 2016 09:49:58 +0300
Message-ID: <87zilr61ux.fsf@kamboji.qca.qualcomm.com>
References: <20161017220342.1627073-1-arnd@arndb.de>
        <20161017221355.1861551-7-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
        =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38418 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753251AbcJZGuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 02:50:10 -0400
In-Reply-To: <20161017221355.1861551-7-arnd@arndb.de> (Arnd Bergmann's message
        of "Tue, 18 Oct 2016 00:13:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> A bugfix added a sanity check around the assignment and use of the
> 'is_11d' variable, which looks correct to me, but as the function is
> rather complex already, this confuses the compiler to the point where
> it can no longer figure out if the variable is always initialized
> correctly:
>
> brcm80211/brcmfmac/cfg80211.c: In function =E2=80=98brcmf_cfg80211_start_=
ap=E2=80=99:
> brcm80211/brcmfmac/cfg80211.c:4586:10: error: =E2=80=98is_11d=E2=80=99 ma=
y be used uninitialized in this function [-Werror=3Dmaybe-uninitialized]
>
> This adds an initialization for the newly introduced case in which
> the variable should not really be used, in order to make the warning
> go away.
>
> Fixes: b3589dfe0212 ("brcmfmac: ignore 11d configuration errors")
> Cc: Hante Meuleman <hante.meuleman@broadcom.com>
> Cc: Arend van Spriel <arend.vanspriel@broadcom.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Via which tree are you planning to submit this? Should I take it?

--=20
Kalle Valo
