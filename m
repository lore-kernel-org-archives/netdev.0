From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio: dmascc: avoid -Wformat-overflow warning
Date: Wed, 26 Jul 2017 09:41:29 -0700 (PDT)
Message-ID: <20170726.094129.1536229682167646914.davem@davemloft.net>
References: <20170726075548.2736340-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, dhowells@redhat.com, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726075548.2736340-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Jul 2017 09:55:33 +0200

> gcc warns that the device name might overflow:
> 
> drivers/net/hamradio/dmascc.c: In function 'dmascc_init':
> drivers/net/hamradio/dmascc.c:584:22: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
>    sprintf(dev->name, "dmascc%i", 2 * n + i);
> drivers/net/hamradio/dmascc.c:584:3: note: 'sprintf' output between 8 and 17 bytes into a destination of size 16
>    sprintf(dev->name, "dmascc%i", 2 * n + i);
> 
> From the static data in this file, I can tell that the index is
> strictly limited to 16, so it won't overflow. This simply changes
> the sprintf() to snprintf(), which is a good idea in general,
> and shuts up this warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next.
