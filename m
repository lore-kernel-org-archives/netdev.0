From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: conntrack: Force inlining of build check to
 prevent build failure
Date: Wed, 3 May 2017 14:32:31 +0200
Message-ID: <CAK8P3a23oEo1zYdFD2nSFzvEc6SF_hoW+4OBig_SY3C1oHJA+g@mail.gmail.com>
References: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33759 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdECMcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 08:32:32 -0400
In-Reply-To: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 2:18 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> If gcc (e.g. 4.1.2) decides not to inline total_extension_size(), the
> build will fail with:
>
>     net/built-in.o: In function `nf_conntrack_init_start':
>     (.text+0x9baf6): undefined reference to `__compiletime_assert_1893'
>
> or
>
>     ERROR: "__compiletime_assert_1893" [net/netfilter/nf_conntrack.ko] undefined!
>
> Fix this by forcing inlining of total_extension_size().
>
> Fixes: b3a5db109e0670d6 ("netfilter: conntrack: use u8 for extension sizes again")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

I saw this as well when I tried building with "gcc-7 -Og", and came to the same
conclusion.

Acked-by: Arnd Bergmann <arnd@arndb.de>

With -Og, there were a couple of other instances of BUILD_BUG_ON() failing
to see a compile-time constant, presumably as it fails to inline any functions
that are not explicitly marked inline.

       Arnd
