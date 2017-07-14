From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/22] liquidio: fix possible eeprom format string
 overflow
Date: Fri, 14 Jul 2017 09:04:08 -0700 (PDT)
Message-ID: <20170714.090408.1884235496293241466.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-14-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, gregkh@linuxfoundation.org,
        torvalds@linux-foundation.org, linux@roeck-us.net,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        weilin.chang@cavium.com, prasad.kanneganti@cavium.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-14-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:05 +0200

> gcc reports that the temporary buffer for computing the
> string length may be too small here:
> 
> drivers/net/ethernet/cavium/liquidio/lio_ethtool.c: In function 'lio_get_eeprom_len':
> /drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:21: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
>   len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
>                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:6: note: 'sprintf' output between 35 and 167 bytes into a destination of size 128
>   len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
> 
> This extends it to 192 bytes, which is certainly enough. As far
> as I could tell, there are no other constraints that require a specific
> maximum size.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
