From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mlxsw: avoid unused variable warnings
Date: Wed, 23 Mar 2016 17:51:11 +0100
Message-ID: <20160323165111.GJ5250@lunn.ch>
References: <1458751080-2044921-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55535 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbcCWQvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 12:51:17 -0400
Content-Disposition: inline
In-Reply-To: <1458751080-2044921-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 05:37:38PM +0100, Arnd Bergmann wrote:
> dev_dbg_ratelimited() is a macro that ignores its arguments when DEBUG is
> not set, which can lead to unused variable warnings:
> 
> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_sdq_handle':
> ethernet/mellanox/mlxsw/pci.c:646:18: warning: unused variable 'pdev' [-Wunused-variable]
> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_rdq_handle':
> ethernet/mellanox/mlxsw/pci.c:671:18: warning: unused variable 'pdev' [-Wunused-variable]
> 
> This changes the mlxsw driver to remove the local variables we get
> warnings for and instead pass the device directly into the API.

Hi Arnd

Would it not be better to fix the macro?

I think the issue is that dev_dbg_ratelimited calls no_printk(),
without making use of dev. So how about:

#define dev_dbg_ratelimited(dev, fmt, ...)                              \
({                                                                      \
        if (0)                                                          \
                dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);        \
})

This follows the pattern for other macros for when DEBUG is not defined.

      Andrew
