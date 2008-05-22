From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] ehea: Fix use after free on reboot
Date: Thu, 22 May 2008 06:04:31 -0400
Message-ID: <4835452F.1010708@garzik.org>
References: <12107765041509-patch-mail.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tklein@de.ibm.com, raisch@de.ibm.com, hering2@de.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44723 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764756AbYEVKF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:05:27 -0400
In-Reply-To: <12107765041509-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian King wrote:
> Fixes the following use after free oops:
> 
> ehea: Reboot: freeing all eHEA resources
> Unable to handle kernel paging request for data at address 0x6b6b6b6b6b6b6c5b
> Faulting instruction address: 0xd000000000354488
> cpu 0x0: Vector: 300 (Data Access) at [c00000002ec6f310]
>     pc: d000000000354488: .ehea_shutdown_single_port+0x50/0x78 [ehea]
>     lr: d00000000035447c: .ehea_shutdown_single_port+0x44/0x78 [ehea]
>     sp: c00000002ec6f590
>    msr: 8000000000009032
>    dar: 6b6b6b6b6b6b6c5b
>  dsisr: 40000000
>   current = 0xc0000000281412e0
>   paca    = 0xc0000000006df300
>     pid   = 10930, comm = reboot
> enter ? for help
> [c00000002ec6f590] d00000000035d64c .ehea_remove+0x44/0x124 [ehea] (unreliable)
> [c00000002ec6f630] c000000000319f88 .of_platform_device_remove+0x40/0x58
> [c00000002ec6f6a0] c000000000291018 .__device_release_driver+0xb0/0xf0
> [c00000002ec6f730] c000000000291120 .driver_detach+0xc8/0xfc
> [c00000002ec6f7c0] c00000000028fe24 .bus_remove_driver+0xb4/0x114
> [c00000002ec6f850] c000000000291768 .driver_unregister+0x54/0x74
> [c00000002ec6f8e0] c00000000031a0c8 .of_unregister_driver+0x14/0x28
> [c00000002ec6f950] c000000000023ba0 .ibmebus_unregister_driver+0x10/0x24
> [c00000002ec6f9c0] d000000000354180 .ehea_reboot_notifier+0x30/0x4c [ehea]
> [c00000002ec6fa40] c0000000003c95a8 .notifier_call_chain+0x5c/0xcc
> [c00000002ec6fae0] c000000000082cd4 .__blocking_notifier_call_chain+0x70/0xb0
> [c00000002ec6fb90] c000000000075cf8 .kernel_restart_prepare+0x24/0x58
> [c00000002ec6fc10] c000000000075f0c .kernel_restart+0x20/0x6c
> [c00000002ec6fc90] c000000000078674 .sys_reboot+0x1d4/0x290
> [c00000002ec6fe30] c0000000000086ac syscall_exit+0x0/0x40
> --- Exception: c01 (System Call) at 000000000ff63a40
> SP (ffceea50) is in userspace
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

applied


