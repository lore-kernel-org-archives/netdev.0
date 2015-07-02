From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: amd-xgbe e0700000.xgmac: DMA-API: device driver tries to sync
 DMA memory it has not allocated
Date: Thu, 2 Jul 2015 18:54:55 -0500
Message-ID: <5595CF4F.3090301@amd.com>
References: <20150702140228.4f5810f07ca869fc54457b9f@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Kim Phillips <kim.phillips@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:56674
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754239AbbGBXzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 19:55:05 -0400
In-Reply-To: <20150702140228.4f5810f07ca869fc54457b9f@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2015 02:02 PM, Kim Phillips wrote:
> Hi Tom,
>
> A pristine 4.1 kernel with CONFIG_DMA_API_DEBUG=y produces this call
> trace on an AMD Seattle:
>
> [  112.896576] ------------[ cut here ]------------
> [  112.896591] WARNING: CPU: 2 PID: 1059 at lib/dma-debug.c:1202 check_sync+0x138/0x56c()
> [  112.896597] amd-xgbe e0700000.xgmac: DMA-API: device driver tries to sync DMA memory it has not allocated [device address=0x0000008003d52000] [size=1536 bytes]
> [  112.896600] Modules linked in: cpufreq_stats vfat fat xfs libcrc32c spi_pl022 aes_ce_blk ablk_helper cryptd aes_ce_cipher ghash_ce sha2_ce sha1_ce uio_pdrv_genirq uio fuse
> [  112.896634] CPU: 2 PID: 1059 Comm: sshd Tainted: G        W       4.1.0 #10
> [  112.896638] Hardware name: Default string Default string/Default string, BIOS ROD0082B 06/16/2015
> [  112.896641] Call trace:
> [  112.899086] [<fffffe0000097b20>] dump_backtrace+0x0/0x170
> [  112.899091] [<fffffe0000097cb0>] show_stack+0x20/0x2c
> [  112.899097] [<fffffe0000813da0>] dump_stack+0x8c/0xc4
> [  112.899102] [<fffffe00000c45bc>] warn_slowpath_common+0xa0/0xd8
> [  112.899106] [<fffffe00000c4668>] warn_slowpath_fmt+0x74/0x88
> [  112.899109] [<fffffe0000486f24>] check_sync+0x134/0x56c
> [  112.899113] [<fffffe00004873ac>] debug_dma_sync_single_for_cpu+0x50/0x5c
> [  112.899119] [<fffffe00005b07fc>] xgbe_rx_poll+0x1e0/0x6c0
> [  112.899123] [<fffffe00005b1cdc>] xgbe_one_poll+0x34/0x6c
> [  112.899128] [<fffffe00006a510c>] net_rx_action+0x270/0x504
> [  112.899133] [<fffffe00000c9ba0>] __do_softirq+0x120/0x60c
> [  112.899136] [<fffffe00000ca3fc>] irq_exit+0xa4/0xe4
> [  112.899143] [<fffffe000012d2f8>] __handle_domain_irq+0x74/0xc4
> [  112.899146] [<fffffe00000903ec>] gic_handle_irq+0x38/0x84
> [  112.899150] Exception stack(0xfffffe03de09bbf0 to 0xfffffe03de09bd10)
> [  112.899154] bbe0:                                     1ee64b30 fffffe00 002111e8 fffffe00
> [  112.899158] bc00: de09bd30 fffffe03 0081a668 fffffe00 dd54fa00 fffffe03 de09bcb0 fffffe03
> [  112.899162] bc20: 00000001 ffffffff 00000001 00000000 00000000 00000000 00000000 00000000
> [  112.899166] bc40: 00000000 00000000 002111e8 fffffe00 00000000 00000000 de098000 fffffe03
> [  112.899170] bc60: de09bc10 fffffe03 1d456228 00000000 00000076 00000000 00000008 00000000
> [  112.899174] bc80: 10000000 00077d2a 00000000 001dcd65 00213e98 fffffe00 96ea8f60 000003ff
> [  112.899178] bca0: 65b9a2e2 00000000 1ee64b30 fffffe00 002111e8 fffffe00 1ee64ba0 fffffe00
> [  112.899181] bcc0: 00000041 00000000 1ee10b80 fffffe00 025c58c8 fffffe00 00000003 00000000
> [  112.899185] bce0: 027b6c48 fffffe00 00100077 00000000 02ab0b4b 00000000 de09bd30 fffffe03
> [  112.899188] bd00: 0081a660 fffffe00 de09bd30 fffffe03
> [  112.899192] [<fffffe00000934e8>] el1_irq+0x68/0x100
> [  112.899198] [<fffffe00002111e4>] validate_mm+0x44/0x2d4
> [  112.899203] [<fffffe0000211edc>] vma_link+0x98/0xe0
> [  112.899206] [<fffffe0000213e70>] do_brk+0x2ec/0x314
> [  112.899209] [<fffffe0000213fd4>] SyS_brk+0x13c/0x170
> [  112.899212] ---[ end trace cbf36648db00d232 ]---
>
> Can you look into it?

Sorry about the top posting earlier.  Should have a fix sent to the list
early next week.

Thanks,
Tom

>
> Thanks,
>
> Kim
>
>
> -- IMPORTANT NOTICE: The contents of this email and any attachments are confidential and may also be privileged. If you are not the intended recipient, please notify the sender immediately and do not disclose the contents to any other person, use it for any purpose, or store or copy the information in any medium.  Thank you.
>
> ARM Limited, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2557590
> ARM Holdings plc, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2548782
>
