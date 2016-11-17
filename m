From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wireless: fix bogus maybe-uninitialized warning
Date: Thu, 17 Nov 2016 06:46:55 +0000 (UTC)
Message-ID: <20161117064655.B2591615D8@smtp.codeaurora.org>
References: <20161024153918.2810634-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Jouni Malinen <j@w1.fi>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44964 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938752AbcKQGq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 01:46:56 -0500
In-Reply-To: <20161024153918.2810634-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:
> The hostap_80211_rx() function is supposed to set up the mac addresses
> for four possible cases, based on two bits of input data. For
> some reason, gcc decides that it's possible that none of the these
> four cases apply and the addresses remain uninitialized:
> 
> drivers/net/wireless/intersil/hostap/hostap_80211_rx.c: In function ‘hostap_80211_rx’:
> arch/x86/include/asm/string_32.h:77:14: warning: ‘src’ may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/wireless/intel/ipw2x00/libipw_rx.c: In function ‘libipw_rx’:
> arch/x86/include/asm/string_32.h:77:14: error: ‘dst’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> arch/x86/include/asm/string_32.h:78:22: error: ‘*((void *)&dst+4)’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This warning is clearly nonsense, but changing the last case into
> 'default' makes it obvious to the compiler too, which avoids the
> warning and probably leads to better object code too.
> 
> The same code is duplicated several times in the kernel, so this
> patch uses the same workaround for all copies. The exact configuration
> was hit only very rarely in randconfig builds and I only saw it
> in three drivers, but I assume that all of them are potentially
> affected, and it's better to keep the code consistent.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

10f3366b4d89 wireless: fix bogus maybe-uninitialized warning

-- 
https://patchwork.kernel.org/patch/9392385/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
