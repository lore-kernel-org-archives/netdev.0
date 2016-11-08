From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: mii: report 0 for unknown lp_advertising
Date: Tue, 08 Nov 2016 14:37:09 +0100
Message-ID: <2691679.uD93atpuSb@wuerfel>
References: <20161108133232.1571441-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108133232.1571441-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, November 8, 2016 2:31:38 PM CET Arnd Bergmann wrote:
> The newly introduced mii_ethtool_get_link_ksettings function sets
> lp_advertising to an uninitialized value when BMCR_ANENABLE is not
> set:
> 
> drivers/net/mii.c: In function 'mii_ethtool_get_link_ksettings':
> drivers/net/mii.c:224:2: error: 'lp_advertising' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> As documented in include/uapi/linux/ethtool.h, the value is
> expected to be zero when we don't know it, so let's initialize
> it to that.
> 
> Fixes: bc8ee596afe8 ("net: mii: add generic function to support ksetting support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

In case there was any doubt: the patch causing this is currently in net-next
and has just shown up in linux-next.

	Arnd
