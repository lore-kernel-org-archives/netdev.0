From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Tue, 27 May 2008 00:21:15 +0200
Message-ID: <483B37DB.707@krogh.cc>
References: <20080526.123338.161271834.davem@davemloft.net>	<20080526.123951.260448303.davem@davemloft.net>	<483B239D.4090402@krogh.cc> <20080526.151540.191673092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:51045 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442AbYEZWV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 18:21:28 -0400
In-Reply-To: <20080526.151540.191673092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Mon, 26 May 2008 22:54:53 +0200
> 
>> Applied and running.. I've now pushed 400GB of data through it trying to
>> get it to hit the bug but it is still running.
>>
>> So without saying that it solved the problem, it definately seems so.
>> 2.6.26-rc4 + above patch.
> 
> Thanks for testing.

I got this one:
(also reported in the linux-2.6.26-rc4 thread)

42949399.810959] ck804xrom ck804xrom_init_one(): Unable to register 
resource 0x0000000000000000-0x00000000ffffffff - kernel bug?
[42949399.979924] ------------[ cut here ]------------
[42949399.979924] WARNING: at arch/x86/mm/ioremap.c:159 
__ioremap_caller+0x299/0x330()
[42949399.979924] Modules linked in: ck804xrom(+) mtd i2c_nforce2(+) 
niu(+) i2c_core serio_raw button(+) chipreg map_funcs pcspkr k8temp 
shpchp pci_hotplug evdev joydev ext3 jbd mbcache pata_amd sr_mod cdrom 
sg sd_mod usb_storage libusual pata_acpi usbhid hid mptsas ata_generic 
mptspi scsi_transport_sas mptscsih mptbase libata scsi_transport_spi 
ehci_hcd e1000 scsi_mod dock ohci_hcd usbcore dm_mirror dm_log 
dm_snapshot dm_mod thermal processor fan fuse
[42949399.979924] Pid: 5660, comm: modprobe Not tainted 2.6.26-rc4 #1
[42949399.979924]
[42949399.979924] Call Trace:
[42949399.979924]  [<ffffffff80236aa4>] warn_on_slowpath+0x64/0xa0
[42949399.979924]  [<ffffffff8034b697>] idr_get_empty_slot+0xf7/0x280
[42949399.979924]  [<ffffffff80237b4e>] printk+0x4e/0x60
[42949399.979924]  [<ffffffff80465e52>] klist_iter_exit+0x12/0x20
[42949399.979924]  [<ffffffff80223139>] __ioremap_caller+0x299/0x330
[42949399.979924]  [<ffffffffa00ee1f6>] 
:ck804xrom:init_ck804xrom+0x1f6/0x631
[42949399.979924]  [<ffffffffa00ee1f6>] 
:ck804xrom:init_ck804xrom+0x1f6/0x631
[42949399.979924]  [<ffffffff8025c23a>] sys_init_module+0x17a/0x1d00
[42949399.979924]  [<ffffffff8028c228>] vma_prio_tree_insert+0x28/0x60
[42949399.979924]  [<ffffffff8020c2bb>] system_call_after_swapgs+0x7b/0x80
[42949399.979924]
[42949399.979924] ---[ end trace 5bb785355abc57e6 ]---
[42949399.979924] ck804xrom: ioremap(00000000, 100000000) failed

(to me it seemed unrelated, but I definately not an expert in this)

-- 
Jesper
