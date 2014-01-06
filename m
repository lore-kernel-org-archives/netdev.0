From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] isdn: Mark build for telespci and hfc_pci as broken
 for big endian ARM
Date: Sun, 05 Jan 2014 20:39:59 -0500 (EST)
Message-ID: <20140105.203959.962622308205839285.davem@davemloft.net>
References: <1388951367-7411-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388951367-7411-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun,  5 Jan 2014 11:49:27 -0800

> With arm:allmodconfig, building the Teles PCI driver fails with
> 
> telespci.c:294:2: error: #error "not running on big endian machines now"
> 
> Similar, building the driver for HFC PCI-Bus cards fails with
> 
> hfc_pci.c:1647:2: error: #error "not running on big endian machines now"
> 
> Mark build as broken for big endian ARM machines.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Let's not start getting into the habit of doing this, please.

The reason this isn't easy to do generically from Kconfig is
probably because it almost never makes any sense to do so.

In fact, if you look at telespci.c there are no DMA descriptors,
everything is read using MMIO acccesses via the chips FIFO.  There
really can't be any endianness problems that I see.

Please just remove the CPP checks, that's the best fix.

Thanks.
