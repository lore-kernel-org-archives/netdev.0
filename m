From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix memory hotplug oops
Date: Wed, 11 May 2011 21:38:34 -0700 (PDT)
Message-ID: <20110511.213834.226764645.davem@davemloft.net>
References: <20110511121710.05ab8c2e@kryten>
	<4DCA853B.6060904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46119
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab1ELEjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 00:39:07 -0400
In-Reply-To: <4DCA853B.6060904@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Wed, 11 May 2011 09:46:51 -0300

> On 05/10/2011 11:17 PM, Anton Blanchard wrote:
>>
>>  The ehea driver oopses during memory hotplug if the ports are not
>>  up. A simple testcase:
>>
>>  # ifconfig ethX down
>>  # echo offline > /sys/devices/system/memory/memory32/state
>>
>>  Oops: Kernel access of bad area, sig: 11 [#1]
>>  last sysfs file: /sys/devices/system/memory/memory32/state
>>  REGS: c000000709393110 TRAP: 0300 Not tainted 
> (2.6.39-rc2-01385-g7ef73bc-dirty)
>>  DAR: 0000000000000000, DSISR: 40000000
>>  ...
>>  NIP [c000000000067c98] .__wake_up_common+0x48/0xf0
>>  LR [c00000000006d034] .__wake_up+0x54/0x90
>>  Call Trace:
>>  [c00000000006d034] .__wake_up+0x54/0x90
>>  [d000000006bb6270] .ehea_rereg_mrs+0x140/0x730 [ehea]
>>  [d000000006bb69c4] .ehea_mem_notifier+0x164/0x170 [ehea]
>>  [c0000000006fc8a8] .notifier_call_chain+0x78/0xf0
>>  [c0000000000b3d70] .__blocking_notifier_call_chain+0x70/0xb0
>>  [c000000000458d78] .memory_notify+0x28/0x40
>>  [c0000000001871d8] .remove_memory+0x208/0x6d0
>>  [c000000000458264] .memory_section_action+0x94/0x140
>>  [c0000000004583ec] .memory_block_change_state+0xdc/0x1d0
>>  [c0000000004585cc] .store_mem_state+0xec/0x160
>>  [c00000000044768c] .sysdev_store+0x3c/0x50
>>  [c00000000020b48c] .sysfs_write_file+0xec/0x1f0
>>  [c00000000018f86c] .vfs_write+0xec/0x1e0
>>  [c00000000018fa88] .SyS_write+0x58/0xd0
>>
>>  To fix this, initialise the waitqueues during port probe instead
>>  of port open.
>>
>>  Signed-off-by: Anton Blanchard <anton@samba.org>
> Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied to net-2.6, thanks.
