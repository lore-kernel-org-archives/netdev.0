From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] qlge: avoid memcpy buffer overflow
Date: Thu, 24 Aug 2017 14:01:37 -0700 (PDT)
Message-ID: <20170824.140137.2014331371813442270.davem@davemloft.net>
References: <20170823135958.1379527-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, stable@vger.kernel.org,
        keescook@chromium.org, gustavo@embeddedor.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823135958.1379527-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 23 Aug 2017 15:59:49 +0200

> gcc-8.0.0 (snapshot) points out that we copy a variable-length string
> into a fixed length field using memcpy() with the destination length,
> and that ends up copying whatever follows the string:
> 
>     inlined from 'ql_core_dump' at drivers/net/ethernet/qlogic/qlge/qlge_dbg.c:1106:2:
> drivers/net/ethernet/qlogic/qlge/qlge_dbg.c:708:2: error: 'memcpy' reading 15 bytes from a region of size 14 [-Werror=stringop-overflow=]
>   memcpy(seg_hdr->description, desc, (sizeof(seg_hdr->description)) - 1);
> 
> Changing it to use strncpy() will instead zero-pad the destination,
> which seems to be the right thing to do here.
> 
> The bug is probably harmless, but it seems like a good idea to address
> it in stable kernels as well, if only for the purpose of building with
> gcc-8 without warnings.
> 
> Cc: stable@vger.kernel.org

Please don't use explicit stable CC:'ing for networking changes.

> Fixes: a61f80261306 ("qlge: Add ethtool register dump function.")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to 'net' and queued up for -stable, thanks.
