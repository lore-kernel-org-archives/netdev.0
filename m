From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [patch net-next 0/8] ipv4: fib: Allow modules to dump FIB tables
Date: Wed, 16 Nov 2016 08:38:13 -0800
Message-ID: <CAKgT0Ud134-+QtxJYGmeyPXY4hZpC1rV_oDkUXSF5wJ9oeTYxQ@mail.gmail.com>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
        roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        nikolay@cumulusnetworks.com, Andy Gospodarek <andy@greyhouse.net>,
        vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35520 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcKPQiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:38:15 -0500
Received: by mail-it0-f66.google.com with SMTP id b123so8243246itb.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 08:38:15 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 6:08 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Ido says:
>
> In kernel 4.9 the switchdev-specific FIB offload mechanism was replaced
> by a new FIB notification chain to which modules could register in order
> to be notified about the addition and deletion of FIB entries. The
> motivation for this change was that switchdev drivers need to be able to
> reflect the entire FIB table and not only FIBs configured on top of the
> port netdevs themselves. This is useful in case of in-band management.
>
> The fundamental problem with this approach is that upon registration
> listeners lose all the information previously sent in the chain and
> thus have an incomplete view of the FIB tables, which can result in
> packet loss. This patchset fixes that by introducing a new API to dump
> the FIB tables.
>
> The entire dump process is done under RCU and thus the FIB notification
> chain is converted to be atomic. The listeners are modified accordingly.
> This is done in the first five patches.
>
> The sixth patch adds the dump callback itself and the next patches call
> it from current listeners of the FIB notification chain.
>
> Ido Schimmel (8):
>   ipv4: fib: Export free_fib_info()
>   mlxsw: spectrum_router: Implement FIB offload in delayed work
>   rocker: Implement FIB offload in delayed work
>   ipv4: fib: Convert FIB notification chain to be atomic
>   net: ipv4: Send notifications only after removing FIB alias
>   ipv4: fib: Add an API to request a FIB dump
>   mlxsw: spectrum_router: Request a dump of FIB tables during init
>   rocker: Request a dump of FIB tables during init
>
>  drivers/net/ethernet/mellanox/mlxsw/core.c         |   6 +
>  drivers/net/ethernet/mellanox/mlxsw/core.h         |   1 +
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  73 ++++++++++--
>  drivers/net/ethernet/rocker/rocker_main.c          |  59 ++++++++--
>  drivers/net/ethernet/rocker/rocker_ofdpa.c         |   1 +
>  include/net/ip_fib.h                               |   1 +
>  net/ipv4/fib_semantics.c                           |   1 +
>  net/ipv4/fib_trie.c                                | 128 +++++++++++++++++++--
>  8 files changed, 242 insertions(+), 28 deletions(-)
>

So for the pieces related to the fib_trie itself this patch series
looks good to me.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
