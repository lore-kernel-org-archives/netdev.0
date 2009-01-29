From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Thu, 29 Jan 2009 17:06:35 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop> <20090129184215.GA13459@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:3289 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbZA2WGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 17:06:46 -0500
In-Reply-To: <20090129184215.GA13459@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 29 Jan 2009, Matt Carlson wrote:

> Can you apply the following test patch and see if it helps?  The patch
> does two things.  First, it enables a bit which should restore firmware
> communication.  If that fixes the problem, then let me know and I'll
> spin a proper patch.
> 
> In the event that it doesn't work, the patch goes on to test the memory
> mapping by simply printing the register value at offset 0x0.  The value
> should be the device's vendor ID and device ID.  Please post the
> results so that I can verify it.
> 
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 8b3f846..39fce42 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -7227,6 +7227,11 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
>  {
>  	tg3_switch_clocks(tp);
>  
> +	printk( KERN_NOTICE "%s: Reg value at offset 0x0 is 0x%x\n",
> +		tp->dev->name, tr32(0x0) );
> +
> +	tw32(MEMARB_MODE, tr32(MEMARB_MODE) | MEMARB_MODE_ENABLE);
> +
>  	tw32(TG3PCI_MEM_WIN_BASE_ADDR, 0);
>  
>  	return tg3_reset_hw(tp, reset_phy);
> 

Hi Matt,

Thanks for the patch. It didn't help with resume - but below is the 
output after patching, let me know if you need more details.

( Looks like 0xffffffff is invalid/corrupted device id /vendor id? )

[  163.856001] tg3 0000:0e:00.0: restoring config space at offset 0xc (was 0x0, writing 0x20040000)                                                                                                            
[  163.856001] tg3 0000:0e:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x10)                                                                                                                  
[  163.856001] tg3 0000:0e:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100006)                                                                                                         

[snip]

[  164.450277] pcieport-driver 0000:1e:00.0: setting latency timer to 64
[  164.450415] pcieport-driver 0000:1e:01.0: setting latency timer to 64
[  164.450493] tg3 0000:0e:00.0: restoring config space at offset 0xc (was 0x0, writing 0x20040000)
[  164.451110] serial 00:08: activated

[snip]

[  168.913863] Restarting tasks ... done.
[  170.332953] tg3 0000:0e:00.0: wake-up capability disabled by ACPI
[  170.332960] tg3 0000:0e:00.0: PME# disabled
[  170.333047] tg3 0000:0e:00.0: irq 54 for MSI/MSI-X
[  170.333250] eth0: Reg value at offset 0x0 is 0xffffffff
[  170.394281] [drm] Loading R500 Microcode
[  170.394330] [drm] Num pipes: 1
[  171.726650] tg3: eth0: No firmware running.
[  183.119745] ADDRCONF(NETDEV_UP): eth0: link is not ready


Parag
