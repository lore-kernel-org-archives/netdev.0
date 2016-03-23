From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mlxsw: avoid unused variable warnings
Date: Wed, 23 Mar 2016 14:38:05 -0400 (EDT)
Message-ID: <20160323.143805.310789862506977932.davem@davemloft.net>
References: <1458751080-2044921-1-git-send-email-arnd@arndb.de>
	<20160323165111.GJ5250@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, jiri@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160323165111.GJ5250@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 23 Mar 2016 17:51:11 +0100

> On Wed, Mar 23, 2016 at 05:37:38PM +0100, Arnd Bergmann wrote:
>> dev_dbg_ratelimited() is a macro that ignores its arguments when DEBUG is
>> not set, which can lead to unused variable warnings:
>> 
>> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_sdq_handle':
>> ethernet/mellanox/mlxsw/pci.c:646:18: warning: unused variable 'pdev' [-Wunused-variable]
>> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_rdq_handle':
>> ethernet/mellanox/mlxsw/pci.c:671:18: warning: unused variable 'pdev' [-Wunused-variable]
>> 
>> This changes the mlxsw driver to remove the local variables we get
>> warnings for and instead pass the device directly into the API.
> 
> Hi Arnd
> 
> Would it not be better to fix the macro?
> 
> I think the issue is that dev_dbg_ratelimited calls no_printk(),
> without making use of dev. So how about:
> 
> #define dev_dbg_ratelimited(dev, fmt, ...)                              \
> ({                                                                      \
>         if (0)                                                          \
>                 dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);        \
> })
> 
> This follows the pattern for other macros for when DEBUG is not defined.

Yeah, this is probably a better way to fix this problem.
