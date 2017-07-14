From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/22] bnx2x: fix format overflow warning
Date: Fri, 14 Jul 2017 09:03:46 -0700 (PDT)
Message-ID: <20170714.090346.1021214085207295498.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-11-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Yuval.Mintz@cavium.com,
        ariel.elior@cavium.com, everest-linux-l2@cavium.com,
        gregkh@linuxfoundation.org, torvalds@linux-foundation.org,
        linux@roeck-us.net, akpm@linux-foundation.org,
        netdev@vger.kernel.org, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, linux-scsi@vger.kernel.org,
        x86@kernel.org, colin.king@canonical.com, tremyfr@gmail.com
To: arnd@arndb.de
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-11-arnd@arndb.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:02 +0200

> gcc notices that large queue numbers would overflow the queue name
> string:
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c: In function 'bnx2x_get_strings':
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:25: error: '%d' directive writing between 1 and 10 bytes into a region of size 5 [-Werror=format-overflow=]
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:25: note: directive argument in the range [0, 2147483647]
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c:3165:5: note: 'sprintf' output between 2 and 11 bytes into a destination of size 5
> 
> There is a hard limit in place that makes the number at most two
> digits, so the code is fine. This changes it to use snprintf()
> to truncate instead of overflowing, which shuts up that warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
