From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Fix memory hotplug oops
Date: Wed, 11 May 2011 09:46:51 -0300
Message-ID: <4DCA853B.6060904@linux.vnet.ibm.com>
References: <20110511121710.05ab8c2e@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:50112 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab1EKQB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 12:01:26 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p4B9lSIZ005780
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 06:47:28 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4BChuBd4808866
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 09:43:56 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4BCkqgP029255
	for <netdev@vger.kernel.org>; Wed, 11 May 2011 09:46:52 -0300
In-Reply-To: <20110511121710.05ab8c2e@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2011 11:17 PM, Anton Blanchard wrote:
>
>  The ehea driver oopses during memory hotplug if the ports are not
>  up. A simple testcase:
>
>  # ifconfig ethX down
>  # echo offline > /sys/devices/system/memory/memory32/state
>
>  Oops: Kernel access of bad area, sig: 11 [#1]
>  last sysfs file: /sys/devices/system/memory/memory32/state
>  REGS: c000000709393110 TRAP: 0300 Not tainted 
(2.6.39-rc2-01385-g7ef73bc-dirty)
>  DAR: 0000000000000000, DSISR: 40000000
>  ...
>  NIP [c000000000067c98] .__wake_up_common+0x48/0xf0
>  LR [c00000000006d034] .__wake_up+0x54/0x90
>  Call Trace:
>  [c00000000006d034] .__wake_up+0x54/0x90
>  [d000000006bb6270] .ehea_rereg_mrs+0x140/0x730 [ehea]
>  [d000000006bb69c4] .ehea_mem_notifier+0x164/0x170 [ehea]
>  [c0000000006fc8a8] .notifier_call_chain+0x78/0xf0
>  [c0000000000b3d70] .__blocking_notifier_call_chain+0x70/0xb0
>  [c000000000458d78] .memory_notify+0x28/0x40
>  [c0000000001871d8] .remove_memory+0x208/0x6d0
>  [c000000000458264] .memory_section_action+0x94/0x140
>  [c0000000004583ec] .memory_block_change_state+0xdc/0x1d0
>  [c0000000004585cc] .store_mem_state+0xec/0x160
>  [c00000000044768c] .sysdev_store+0x3c/0x50
>  [c00000000020b48c] .sysfs_write_file+0xec/0x1f0
>  [c00000000018f86c] .vfs_write+0xec/0x1e0
>  [c00000000018fa88] .SyS_write+0x58/0xd0
>
>  To fix this, initialise the waitqueues during port probe instead
>  of port open.
>
>  Signed-off-by: Anton Blanchard <anton@samba.org>
Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>

