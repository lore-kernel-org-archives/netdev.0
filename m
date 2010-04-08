From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Crashes in xfrm_lookup
Date: Thu, 8 Apr 2010 12:14:41 +0100
Message-ID: <20100408111441.GA14241@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo =?unknown-8bit?B?VGVyw6Rz?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:42728 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab0DHLOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:14:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With -next as of today I'm experiencing crashes in the xfrm_lookup code
when attempting to boot from an NFS root on a SMDK6410 (an ARM based
development board).  I'm currently investigating what's gone wrong, but
thought it was better to report early in case it's obvious to someone
familiar with the code or there's a fix already.

Sample backtrace below:

[    6.540000] Unable to handle kernel NULL pointer dereference at virtual addrc
[    6.540000] pgd = c0004000                                                   
[    6.550000] [0000003c] *pgd=00000000                                         
[    6.550000] Internal error: Oops: 5 [#1]                                     
[    6.550000] last sysfs file:                                                 
[    6.550000] Modules linked in:                                               
[    6.550000] CPU: 0    Not tainted (2.6.34-rc3-next-20100408-00011-g3d8ee7a-)
[    6.550000] PC is at __xfrm_lookup+0x308/0x3a8                               
[    6.550000] LR is at ip_route_output_flow+0x7c/0x210                         

...

[    6.550000] [<c02c1394>] (__xfrm_lookup+0x308/0x3a8) from [<c02889a4>] (ip_r)
[    6.550000] [<c02889a4>] (ip_route_output_flow+0x7c/0x210) from [<c02ade9c>])
[    6.550000] [<c02ade9c>] (udp_sendmsg+0x320/0x5ec) from [<c02b3b20>] (inet_s)
[    6.550000] [<c02b3b20>] (inet_sendmsg+0x58/0x64) from [<c02612d8>] (sock_se)
[    6.550000] [<c02612d8>] (sock_sendmsg+0x88/0xa8) from [<c0261338>] (kernel_)
[    6.550000] [<c0261338>] (kernel_sendmsg+0x40/0x7c) from [<c02d0dd0>] (xs_se)
[    6.550000] [<c02d0dd0>] (xs_send_kvec+0x94/0xa4) from [<c02d0e70>] (xs_send)
[    6.550000] [<c02d0e70>] (xs_sendpages+0x90/0x204) from [<c02d1268>] (xs_udp)
[    6.550000] [<c02d1268>] (xs_udp_send_request+0x3c/0x120) from [<c02cf254>] )
[    6.550000] [<c02cf254>] (xprt_transmit+0x158/0x25c) from [<c02cc9c0>] (call)
[    6.550000] [<c02cc9c0>] (call_transmit+0x204/0x284) from [<c02d380c>] (__rp)
[    6.550000] [<c02d380c>] (__rpc_execute+0x94/0x2c4) from [<c02cd35c>] (rpc_r)
[    6.550000] [<c02cd35c>] (rpc_run_task+0x60/0x6c) from [<c02cd4a0>] (rpc_cal)
[    6.550000] [<c02cd4a0>] (rpc_call_sync+0x58/0x84) from [<c02cd51c>] (rpc_pi)
[    6.550000] [<c02cd51c>] (rpc_ping+0x50/0x70) from [<c02cded0>] (rpc_create+)
[    6.550000] [<c02cded0>] (rpc_create+0x3e4/0x498) from [<c013c194>] (nfs_mou)
[    6.550000] [<c013c194>] (nfs_mount+0xd8/0x1c4) from [<c0016d14>] (nfs_root_)
[    6.550000] [<c0016d14>] (nfs_root_data+0x2cc/0x398) from [<c0008fb8>] (moun)
[    6.550000] [<c0008fb8>] (mount_root+0x1c/0x104) from [<c0009204>] (prepare_)
[    6.550000] [<c0009204>] (prepare_namespace+0x164/0x1c8) from [<c0008478>] ()
[    6.550000] [<c0008478>] (kernel_init+0x108/0x148) from [<c002df5c>] (kernel)

