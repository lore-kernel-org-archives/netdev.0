From: Hongmei Li <duckcncn@gmail.com>
Subject: Re: [ask for help and advice] =?utf-8?b?ZmliNl9kZWw=?= triggered =?utf-8?b?QlVHX09OLA==?= because =?utf-8?b?cnQtPnJ0NmlfcmVm?= counter is 2
Date: Fri, 22 Apr 2016 21:06:37 +0000 (UTC)
Message-ID: <loom.20160422T225649-750@post.gmane.org>
References: <56F635EC.6090009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:42255 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750AbcDVVGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 17:06:49 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1atiHm-00018i-Fw
	for netdev@vger.kernel.org; Fri, 22 Apr 2016 23:06:46 +0200
Received: from 144.189.31.1 ([144.189.31.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:06:46 +0200
Received: from duckcncn by 144.189.31.1 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:06:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I encounter the same BUG_ON several times,
rt6i_ref is 2;
rt6i_dst is 0::0

Here is an example trace:

[278451.384635] Kernel BUG at ffffffc000b60238

[278451.384641] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP

[278451.384671] task: ffffffc035f30ac0 
[278451.384683] PC is at fib6_purge_rt+0xd0/0xe4
[278451.384690] LR is at fib6_del+0x230/0x298
[278451.384695] pc : [<ffffffc000b60238>] lr : [<ffffffc000b613b4>] 
[278451.384700] sp : ffffffc02b9d78a0
[278451.384704] x29: ffffffc02b9d78a0 x28: 0000000000000000
[278451.384711] x27: 0000000000000000 x26: 00000000000001c8
[278451.384718] x25: ffffffc02b9d7c80 x24: 0000000000000000
[278451.384726] x23: ffffffc00173ebc0 x22: ffffffc02b9d7a90
[278451.384734] x21: ffffffc000b5f690 x20: 0000000000000000
[278451.384741] x19: ffffffc02dc35c80 x18: 0000007f91a07000
[278451.384749] x17: 0000007f91adc33c x16: ffffffc000a76df0
[278451.384757] x15: 0000000000007330 x14: 0000000000007330
[278451.384764] x13: 0000000000000000 x12: 0000000000000000
[278451.384771] x11: ffffffc02dc35d80 x10: 0000000000000001
[278451.384779] x9 : 0000000000000000 x8 : 000000000000008c
[278451.384786] x7 : ffffffc00460e700 x6 : ffffffc00460e200
[278451.384793] x5 : ffffffc0017426d8 x4 : 0000000000000000
[278451.384800] x3 : ffffffc00174f300 x2 : ffffffc00173ebc0
[278451.384807] x1 : ffffffc02bfe5e98 x0 : 0000000000000002
...
[278451.385322] Process ip
[278451.385327] Call trace:
[278451.385336] [<ffffffc000b60238>] fib6_purge_rt+0xd0/0xe4
[278451.385343] [<ffffffc000b613b0>] fib6_del+0x22c/0x298
[278451.385350] [<ffffffc000b5c1a8>] __ip6_del_rt+0x50/0x7c
[278451.385356] [<ffffffc000b5c2a0>] ip6_route_del+0xcc/0x104
[278451.385363] [<ffffffc000b5e130>] inet6_rtm_delroute+0x44/0x68
[278451.385371] [<ffffffc000a99d7c>] rtnetlink_rcv_msg+0x180/0x1a0
[278451.385378] [<ffffffc000ab4998>] netlink_rcv_skb+0x64/0xc8
[278451.385387] [<ffffffc000a98590>] rtnetlink_rcv+0x1c/0x2c
[278451.385393] [<ffffffc000ab43e4>] netlink_unicast+0x108/0x1b8
[278451.385399] [<ffffffc000ab47d0>] netlink_sendmsg+0x27c/0x2d4
[278451.385407] [<ffffffc000a74ebc>] sock_sendmsg+0x8c/0xb0
[278451.385414] [<ffffffc000a76ebc>] SyS_sendto+0xcc/0x110
[278451.385421] Code: 17ffffdb b940ce60 7100041f 54000040 (e7f001f2)
[278451.385428] ---[ end trace abecf0c88c823f51 ]---
[278451.391859] Kernel panic - not syncing: Fatal exception in interrupt
