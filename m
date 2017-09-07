From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] netfilter: xt_hashlimit: avoid 64-bit division
Date: Thu, 7 Sep 2017 16:16:46 +0200
Message-ID: <CAMuHMdX-yEz5QUb_ZgDki72Csiz05f6s+AmNei=_eZh7qf9-RQ@mail.gmail.com>
References: <20170906195825.3715290-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Vishwanath Pai <vpai@akamai.com>,
        Josh Hunt <johunt@akamai.com>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:38572 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754005AbdIGOQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:16:47 -0400
In-Reply-To: <20170906195825.3715290-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Wed, Sep 6, 2017 at 9:57 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> 64-bit division is expensive on 32-bit architectures, and
> requires a special function call to avoid a link error like:
>
> net/netfilter/xt_hashlimit.o: In function `hashlimit_mt_common':
> xt_hashlimit.c:(.text+0x1328): undefined reference to `__aeabi_uldivmod'
>
> In the case of hashlimit_mt_common, we don't actually need a
> 64-bit operation, we can simply rewrite the function slightly
> to make that clear to the compiler.
>
> Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, this fixes a similar issue (__udivdi3 undefined) on m68k.

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert
