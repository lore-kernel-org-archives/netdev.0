From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] netronome: don't access real_num_rx_queues directly
Date: Wed, 16 Nov 2016 08:37:06 -0800
Message-ID: <CAJpBn1wOyv3G0+3yKoZD4CSTedgQn9TZPygP97539fHYY+rt3A@mail.gmail.com>
References: <20161116141118.1893244-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, oss-drivers@netronome.com,
        netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34890 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbcKPQhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:37:07 -0500
Received: by mail-qk0-f178.google.com with SMTP id n204so182528073qke.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 08:37:07 -0800 (PST)
In-Reply-To: <20161116141118.1893244-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 6:10 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The netdev->real_num_rx_queues setting is only available if CONFIG_SYSFS
> is enabled, so we now get a build failure when that is turned off:
>
> netronome/nfp/nfp_net_common.c: In function 'nfp_net_ring_swap_enable':
> netronome/nfp/nfp_net_common.c:2489:18: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
>
> As far as I can tell, the check here is only used as an optimization that
> we can skip in order to fix the compilation. If sysfs is disabled,
> the following netif_set_real_num_rx_queues() has no effect.
>
> Fixes: 164d1e9e5d52 ("nfp: add support for ethtool .set_channels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks Arnd!  This is needed in net-next only.
