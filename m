From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/22] net: thunder_bgx: avoid format string overflow
 warning
Date: Fri, 14 Jul 2017 09:03:55 -0700 (PDT)
Message-ID: <20170714.090355.1299368178510322895.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-12-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
        gregkh@linuxfoundation.org, torvalds@linux-foundation.org,
        linux@roeck-us.net, akpm@linux-foundation.org,
        netdev@vger.kernel.org, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, linux-scsi@vger.kernel.org,
        x86@kernel.org, tsrinivasulu@cavium.com, george.cherian@cavium.com,
        Vadim.Lomovtsev@caviumnetworks.com, rchintakuntla@cavium.com,
        linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-12-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:03 +0200

> gcc warns that the temporary buffer might be too small here:
> 
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c: In function 'bgx_probe':
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: error: '%d' directive writing between 1 and 10 bytes into a region of size between 9 and 11 [-Werror=format-overflow=]
> sprintf(str, "BGX%d LMAC%d mode", bgx->bgx_id, lmacid);
>              ^~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: note: directive argument in the range [0, 2147483647]
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:3: note: 'sprintf' output between 16 and 27 bytes into a destination of size 20
> 
> This probably can't happen, but it can't hurt to make it long
> enough for the theoretical limit.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
