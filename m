From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: davinci_emac: Fix platform_data
 overwrite
Date: Thu, 21 Apr 2016 14:58:12 -0400 (EDT)
Message-ID: <20160421.145812.877181452329564912.davem@davemloft.net>
References: <1461142605-4335-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, thomas.lendacky@amd.com, mugunthanvnm@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b.hutchman@gmail.com
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461142605-4335-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Wed, 20 Apr 2016 10:56:45 +0200

> When the DaVinci emac driver is removed and re-probed, the actual
> pdev->dev.platform_data is populated with an unwanted valid pointer saved by
> the previous davinci_emac_of_get_pdata() call, causing a kernel crash when
> calling priv->int_disable() in emac_int_disable().
> 
> Unable to handle kernel paging request at virtual address c8622a80
> ...
> [<c0426fb4>] (emac_int_disable) from [<c0427700>] (emac_dev_open+0x290/0x5f8)
> [<c0427700>] (emac_dev_open) from [<c04c00ec>] (__dev_open+0xb8/0x120)
> [<c04c00ec>] (__dev_open) from [<c04c0370>] (__dev_change_flags+0x88/0x14c)
> [<c04c0370>] (__dev_change_flags) from [<c04c044c>] (dev_change_flags+0x18/0x48)
> [<c04c044c>] (dev_change_flags) from [<c052bafc>] (devinet_ioctl+0x6b4/0x7ac)
> [<c052bafc>] (devinet_ioctl) from [<c04a1428>] (sock_ioctl+0x1d8/0x2c0)
> [<c04a1428>] (sock_ioctl) from [<c014f054>] (do_vfs_ioctl+0x41c/0x600)
> [<c014f054>] (do_vfs_ioctl) from [<c014f2a4>] (SyS_ioctl+0x6c/0x7c)
> [<c014f2a4>] (SyS_ioctl) from [<c000ff60>] (ret_fast_syscall+0x0/0x1c)
> 
> Fixes: 42f59967a091 ("net: ethernet: davinci_emac: add OF support")
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Applied.
