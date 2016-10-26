From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 19/28] brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap
Date: Wed, 26 Oct 2016 11:57:23 +0200
Message-ID: <3406231.8mt2808XDi@wuerfel>
References: <20161017220342.1627073-1-arnd@arndb.de> <20161017221355.1861551-7-arnd@arndb.de> <87zilr61ux.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87zilr61ux.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, October 26, 2016 9:49:58 AM CEST Kalle Valo wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> 
> > A bugfix added a sanity check around the assignment and use of the
> > 'is_11d' variable, which looks correct to me, but as the function is
> > rather complex already, this confuses the compiler to the point where
> > it can no longer figure out if the variable is always initialized
> > correctly:
> >
> > brcm80211/brcmfmac/cfg80211.c: In function ‘brcmf_cfg80211_start_ap’:
> > brcm80211/brcmfmac/cfg80211.c:4586:10: error: ‘is_11d’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >
> > This adds an initialization for the newly introduced case in which
> > the variable should not really be used, in order to make the warning
> > go away.
> >
> > Fixes: b3589dfe0212 ("brcmfmac: ignore 11d configuration errors")
> > Cc: Hante Meuleman <hante.meuleman@broadcom.com>
> > Cc: Arend van Spriel <arend.vanspriel@broadcom.com>
> > Cc: Kalle Valo <kvalo@codeaurora.org>
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Via which tree are you planning to submit this? Should I take it?

I'd prefer if you can take it and forward it along with your other
bugfixes. I'll try to take care of the ones that nobody else
picked up.

	Arnd
