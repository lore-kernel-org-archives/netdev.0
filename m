From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v2 0/2] net: mvneta: improve rx performance
Date: Fri, 17 Feb 2017 11:37:21 +0100
Message-ID: <87shndayse.fsf@free-electrons.com>
References: <20170217100233.2325-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36278 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932326AbdBQKh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 05:37:27 -0500
In-Reply-To: <20170217100233.2325-1-jszhang@marvell.com> (Jisheng Zhang's
        message of "Fri, 17 Feb 2017 18:02:31 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,
 
 On ven., févr. 17 2017, Jisheng Zhang <jszhang@marvell.com> wrote:

> In hot code path such as mvneta_rx_hwbm() and mvneta_rx_swbm(), we may
> access fields of rx_desc. The rx_desc is allocated by
> dma_alloc_coherent, it's uncacheable if the device isn't cache
> coherent, reading from uncached memory is fairly slow.

Did you test it with HWBM support?

I am  not sure ti will work in this case.

Gregory

>
> patch1 reuses the read out status to getting status field of rx_desc
> again.
>
> patch2 uses cacheable memory to store the rx buffer DMA address.
>
> We get the following performance data on Marvell BG4CT Platforms
> (tested with iperf):
>
> before the patch:
> recving 1GB in mvneta_rx_swbm() costs 149265960 ns
>
> after the patch:
> recving 1GB in mvneta_rx_swbm() costs 1421565640 ns
>
> We saved 4.76% time.
>
> RFC: can we do similar modification for tx? If yes, I can prepare a v2.
>
>
> Basically, these two patches do what Arnd mentioned in [1].
>
> Hi Arnd,
>
> I added "Suggested-by you" tag, I hope you don't mind ;)
>
> Thanks
>
> [1] https://www.spinics.net/lists/netdev/msg405889.html
>
> Since v1:
>   - correct the performance data typo
>
> Jisheng Zhang (2):
>   net: mvneta: avoid getting status from rx_desc as much as possible
>   net: mvneta: Use cacheable memory to store the rx buffer DMA address
>
>  drivers/net/ethernet/marvell/mvneta.c | 36 ++++++++++++++++++++---------------
>  1 file changed, 21 insertions(+), 15 deletions(-)
>
> -- 
> 2.11.0
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
