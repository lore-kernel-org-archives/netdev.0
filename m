From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rocker: fix Wmaybe-uninitialized false-positive
Date: Tue, 28 Mar 2017 21:42:58 -0700 (PDT)
Message-ID: <20170328.214258.1096589839586809714.davem@davemloft.net>
References: <20170328141126.1541994-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328141126.1541994-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 28 Mar 2017 16:11:18 +0200

> gcc-7 reports a warning that earlier versions did not have:
> 
> drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_port_stp_update':
> arch/x86/include/asm/string_32.h:79:22: error: '*((void *)&prev_ctrls+4)' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    *((short *)to + 2) = *((short *)from + 2);
>    ~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/rocker/rocker_ofdpa.c:2218:7: note: '*((void *)&prev_ctrls+4)' was declared here
> 
> This is clearly a variation of the warning about 'prev_state' that
> was shut up using uninitialized_var().
> 
> We can slightly simplify the code and get rid of the warning by unconditionally
> saving the prev_state and prev_ctrls variables. The inlined memcpy is not
> particularly expensive here, as it just has to read five bytes from one or
> two cache lines.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
