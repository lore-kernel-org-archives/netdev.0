From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next v2 2/2] net: mvneta: Use cacheable memory to store the rx buffer DMA address
Date: Fri, 17 Feb 2017 16:20:34 +0100
Message-ID: <87fujcc08t.fsf@free-electrons.com>
References: <20170217100233.2325-1-jszhang@marvell.com>
        <20170217100233.2325-3-jszhang@marvell.com>
        <87o9y1aqsk.fsf@free-electrons.com>
        <20170217145501.5b90a977@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Jisheng Zhang <jszhang@marvell.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217145501.5b90a977@free-electrons.com> (Thomas Petazzoni's
        message of "Fri, 17 Feb 2017 14:55:01 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,
 
 On ven., févr. 17 2017, Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> Does not make sense, because it's not the SW that refills the RX
> descriptors with the address of the RX buffers. It's done by the HW.
>
> With HWBM, I believe you have no choice but to read the physical
> address from the RX descriptor. But you can probably optimize things a
> little bit by reading it only once, and then storing it into a
> cacheable variable.
>
> So maybe:
>
>  - For SWBM, use the strategy proposed by Jisheng
>  - For HWBM, at the beginning of the RX completion path, read once the
>    rx_desc->buf_phys_addr, and store it in rxq->buf_dma_addr[index]


For the HWBM path storing rx_desc->buf_phys_addr in
rxq->buf_dma_addr[index] is not useful as we only use it in a single
function.

But a quick improvement could be to use the phys_addr variable. Indeed
we store the value of rx_desc->buf_phys_addr in it and we never used it,
instead we always use rx_desc->buf_phys_addr.

Gregory

>
> Of course that's just a very rough proposal. I've been looking mainly
> at mvpp2 lately, and I'm not sure I still remember how mvneta works in
> the details.
>
> Best regards,
>
> Thomas
> -- 
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
