From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH -next] gianfar, ucc_geth: Use proper address translation for MDIO buses
Date: Thu, 19 Mar 2009 03:57:10 -0500
Message-ID: <A41D3E28-93C8-46FD-A87A-EDE6C4D4E77B@kernel.crashing.org>
References: <20090318192152.GA29621@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Scott Wood <scottwood@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51181 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755827AbZCSI56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 04:57:58 -0400
In-Reply-To: <20090318192152.GA29621@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 18, 2009, at 2:21 PM, Anton Vorontsov wrote:

> Currently the drivers just read "reg" property for constructing MDIO
> bus IDs, but this won't work when we'll start using "ranges = <>" in
> the device tree, so this will pop up:
>
> Gianfar MII Bus: probed
> sysfs: duplicate filename 'mdio@520' can not be created
> ------------[ cut here ]------------
> Badness at c00c70c8 [verbose debug info unavailable]
> NIP: c00c70c8 LR: c00c70c8 CTR: c018220c
> REGS: cf82fc80 TRAP: 0700   Not tainted  (2.6.29-rc7-00607-g8deffe6)
> MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 22044022  XER: 20000000
> TASK = cf821bd0[1] 'swapper' THREAD: cf82e000
> GPR00: c00c70c8 cf82fd30 cf821bd0 0000003b 000013a4 ffffffff  
> c017f4f0 000013a4
> GPR08: c03becbc c03b1f5c 000013a4 c03be810 22044022 00000000  
> 0ffcd000 00000000
> GPR16: 0ffc2420 0ffc6eb8 00000000 00000000 00000000 00000000  
> 00000000 00000000
> GPR24: 00000000 00000000 cf9d8c40 cf82fd78 cf86ec14 cf82fd48  
> cf9d78a4 ffffffef
> NIP [c00c70c8] sysfs_add_one+0x4c/0x54
> LR [c00c70c8] sysfs_add_one+0x4c/0x54
> Call Trace:
> [cf82fd30] [c00c70c8] sysfs_add_one+0x4c/0x54 (unreliable)
> [cf82fd40] [c00c7628] create_dir+0x58/0xc0
> [cf82fd70] [c00c76d0] sysfs_create_dir+0x40/0x70
> [cf82fd90] [c0154d58] create_dir+0x28/0x78
> [cf82fda0] [c01551f4] kobject_add_internal+0x98/0x13c
> [cf82fdc0] [c0155868] kobject_add+0x60/0x98
> [cf82fdf0] [c01854f4] device_add+0x98/0x2ac
> [cf82fe10] [c01985d8] mdiobus_register+0xb4/0x1b8
> [cf82fe30] [c0194f1c] gfar_mdio_probe+0x188/0x204
> ...
>
> This patch fixes the issue by translating the "reg" property to a full
> address, and thus avoids the duplicate names.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>
> This is for 2.6.30 since we don't use ranges = <> yet.
>
> David, I believe Kumar would like to pick this patch into his tree
> along with a patch set that adds "ranges = <>" properties to the
> device tree... So would you mind if we take it via powerpc.git?
>
> Thanks,
>
> drivers/net/gianfar_mii.c  |   10 +++++++---
> drivers/net/ucc_geth_mii.c |   10 +++++++---
> 2 files changed, 14 insertions(+), 6 deletions(-)

Andy merged these in net-next to just have drivers/net/fsl_pq_mdio.c.

My suggestion is to update the patch against -next and have David put  
it into net-next.

(I'll deal w/the .dts updates in powerpc.git and cherry pick commits  
out of net-next into my testing branching)

- k
