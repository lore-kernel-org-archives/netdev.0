From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][RESEND] PHY: Add the phy_device_release device method.
Date: Tue, 04 Dec 2007 15:06:49 -0500
Message-ID: <4755B359.4070909@garzik.org>
References: <20071119.214215.207388094.davem@davemloft.net> <4751D9F3.5090502@garzik.org> <20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de> <20071203214440.78709615.akpm@linux-foundation.org> <20071204073847.GA881@avionic-tr-basi.adnet.avionic-design.de> <20071204131733.GA27457@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thierry Reding <thierry.reding@avionic-design.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53398 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbXLDUHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:07:04 -0500
In-Reply-To: <20071204131733.GA27457@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> On Tue, Dec 04, 2007 at 08:38:47AM +0100, Thierry Reding wrote:
>> * Andrew Morton wrote:
>>> On Mon, 3 Dec 2007 09:35:11 +0100 Thierry Reding <thierry.reding@avionic-design.de> wrote:
>>>
> [...]
>>> I've been sitting on
>>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc3/2.6.24-rc3-mm2/broken-out/phy-implement-release-function.patch
>>> for a few weeks.  For some reason I have it in my "nacked netdev patches"
>>> section but I think that was a mistake and it has not (yet ;)) been nacked.
> 
> Heh, it has been otherwise Acked-by: Andy Fleming, informal(?) phylib
> maintainer.
> 
>>> Anyway, Anton's patch looks somewhat different from yours.  Please compare
>>> notes.
>> FWIW, I like Anton's patch better, especially since it plugs a possible
>> memory leak. I'm not sure it's useful or necessary to export the
>> phy_device_free symbol, though.
> 
> Makes sense, I think. Here is the newer patch, the only difference is
> removed EXPORT_SYMBOL(). Because of trivial change, I dared to keep
> Andy's Acked-by intact.
> 
> - - - -
> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Subject: [PATCH] phy: implement release function
> 
> Lately I've got this nice badness on mdio bus removal:
> 
> Device 'e0103120:06' does not have a release() function, it is broken and must be fixed.
> ------------[ cut here ]------------
> Badness at drivers/base/core.c:107
> NIP: c015c1a8 LR: c015c1a8 CTR: c0157488
> REGS: c34bdcf0 TRAP: 0700   Not tainted  (2.6.23-rc5-g9ebadfbb-dirty)
> MSR: 00029032 <EE,ME,IR,DR>  CR: 24088422  XER: 00000000
> ...
> [c34bdda0] [c015c1a8] device_release+0x78/0x80 (unreliable)
> [c34bddb0] [c01354cc] kobject_cleanup+0x80/0xbc
> [c34bddd0] [c01365f0] kref_put+0x54/0x6c
> [c34bdde0] [c013543c] kobject_put+0x24/0x34
> [c34bddf0] [c015c384] put_device+0x1c/0x2c
> [c34bde00] [c0180e84] mdiobus_unregister+0x2c/0x58
> ...
> 
> Though actually there is nothing broken, it just device
> subsystem core expects another "pattern" of resource managment.
> 
> This patch implement phy device's release function, thus
> we're getting rid of this badness.
> 
> Also small hidden bug fixed, hope none other introduced. ;-)
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Acked-by: Andy Fleming <afleming@freescale.com>

applied #upstream-fixes



