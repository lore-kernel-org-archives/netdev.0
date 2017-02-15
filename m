From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: xilinx_emaclite: fix freezes due to unordered
 I/O
Date: Wed, 15 Feb 2017 12:19:41 -0500 (EST)
Message-ID: <20170215.121941.1615540242375929154.davem@davemloft.net>
References: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
        <20170214171145.26953-2-anssi.hannula@bitwise.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org
To: anssi.hannula@bitwise.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752217AbdBORTs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:19:48 -0500
In-Reply-To: <20170214171145.26953-2-anssi.hannula@bitwise.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anssi Hannula <anssi.hannula@bitwise.fi>
Date: Tue, 14 Feb 2017 19:11:45 +0200

> The xilinx_emaclite uses __raw_writel and __raw_readl for register
> accesses. Those functions do not imply any kind of memory barriers and
> they may be reordered.
> 
> The driver does not seem to take that into account, though, and the
> driver does not satisfy the ordering requirements of the hardware.
> For clear examples, see xemaclite_mdio_write() and xemaclite_mdio_read()
> which try to set MDIO address before initiating the transaction.
> 
> I'm seeing system freezes with the driver with GCC 5.4 and current
> Linux kernels on Zynq-7000 SoC immediately when trying to use the
> interface.
> 
> In commit 123c1407af87 ("net: emaclite: Do not use microblaze and ppc
> IO functions") the driver was switched from non-generic
> in_be32/out_be32 (memory barriers, big endian) to
> __raw_readl/__raw_writel (no memory barriers, native endian), so
> apparently the device follows system endianness and the driver was
> originally written with the assumption of memory barriers.
> 
> Rather than try to hunt for each case of missing barrier, just switch
> the driver to use iowrite32/ioread32/iowrite32be/ioread32be depending
> on endianness instead.
> 
> Tested on little-endian Zynq-7000 ARM SoC FPGA.
> 
> Signed-off-by: Anssi Hannula <anssi.hannula@bitwise.fi>
> Fixes: 123c1407af87 ("net: emaclite: Do not use microblaze and ppc IO
> functions")

Applied.
