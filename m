From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: forcedeth hangs on loading
Date: Fri, 30 Nov 2007 15:00:03 -0800
Message-ID: <20071130150003.40559995@freepuppy.rosehill>
References: <474FC13D.6060002@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	devel@openvz.org
To: Vasily Averin <vvs@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38975 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752806AbXK3XB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 18:01:56 -0500
In-Reply-To: <474FC13D.6060002@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Nov 2007 10:52:29 +0300
Vasily Averin <vvs@sw.ru> wrote:

> Hi Ayaz,
> 
> 
> While testing new OpenVZ kernel based on RHEL5.1 kernel 2.6.18-53.el5 we have
> observed that node loads forcedeth driver too long:
> 
> Nov 28 14:04:19 ts49 kjournald starting.  Commit interval 5 seconds
> Nov 28 14:04:19 ts49 EXT3-fs: mounted filesystem with ordered data mode.
> ...
> Nov 28 19:34:47 ts49 modprobe      D ffff8101ff772120     0  4101   4098
>              (NOTLB)
> Nov 28 19:34:47 ts49  ffff8101fe7e1c28 0000000000000086 0000000000000246
> 00000010000200d0
> Nov 28 19:34:47 ts49  ffff8101ff772120 ffff8103ff93c930 000012229b7b3bd7
> 00002bcc55b0dda7
> Nov 28 19:34:47 ts49  ffff8101ff772328 ffff8101ff93a000 ffffffff802de500
> ffff8103ff93c930
> Nov 28 19:34:47 ts49 Call Trace:
> Nov 28 19:34:47 ts49  [<ffffffff80062cc2>] schedule_timeout+0x8a/0xad
> Nov 28 19:34:47 ts49  [<ffffffff80091bf9>] process_timeout+0x0/0x5
> Nov 28 19:34:47 ts49  [<ffffffff800925c0>] msleep+0x21/0x2c
> Nov 28 19:34:47 ts49  [<ffffffff8819fc8f>] :forcedeth:nv_probe+0x873/0xd4d
> Nov 28 19:34:47 ts49  [<ffffffff801427f8>] pci_device_probe+0x100/0x180
> Nov 28 19:34:47 ts49  [<ffffffff8019ff2c>] driver_probe_device+0x52/0xaa
> Nov 28 19:34:47 ts49  [<ffffffff801a005b>] __driver_attach+0x65/0xb6
> Nov 28 19:34:47 ts49  [<ffffffff8019fff6>] __driver_attach+0x0/0xb6
> Nov 28 19:34:47 ts49  [<ffffffff8019f96d>] bus_for_each_dev+0x43/0x6e
> Nov 28 19:34:47 ts49  [<ffffffff8019f5b3>] bus_add_driver+0x7e/0x130
> Nov 28 19:34:47 ts49  [<ffffffff801429dc>] __pci_register_driver+0x57/0x7e
> Nov 28 19:34:47 ts49  [<ffffffff800aa815>] sys_init_module+0x16aa/0x185f
> Nov 28 19:34:47 ts49  [<ffffffff8005e166>] system_call+0x7e/0x83
> ...
> Nov 28 21:02:02 ts49 eth0: forcedeth.c: subsystem: 010f1:2912 bound to 0000:00:08.0
> Nov 28 21:02:02 ts49 ACPI: PCI Interrupt Link [LMA2] enabled at IRQ 18
> Nov 28 21:02:02 ts49 GSI 22 sharing vector 0x3A and IRQ 22
> Nov 28 21:02:02 ts49 ACPI: PCI Interrupt 0000:00:09.0[A] -> Link [LMA2] -> GSI
> 18 (level, high) -> IRQ 58
> Nov 28 21:02:02 ts49 PCI: Setting latency timer of device 0000:00:09.0 to 64
> Nov 28 21:02:02 ts49
> Nov 28 21:02:02 ts49 forcedeth: using HIGHDMA
> Nov 28 21:02:02 ts49 eth1: forcedeth.c: subsystem: 010f1:2912 bound to 0000:00:09.0
> 
> nv_probe() was called under semaphore and blocks lots of other modprobe's from
> loading other drivers.
> 
> linux-2.6-net-forcedeth-update-to-driver-version-0-60.patch patch from RHEL5.1
> added the following piece of code to nv_probe():
> 


Please don't complain about vendor kernel patches on the mainline kernel development
list. Complain to the distribution vendor.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
