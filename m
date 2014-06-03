From: Ben Greear <greearb@candelatech.com>
Subject: Possible memory leak in 3.14.5+ (hacked).
Date: Tue, 03 Jun 2014 11:42:48 -0700
Message-ID: <538E1728.8000804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:43583 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbaFCSmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 14:42:49 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id A0E9A40C697
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 11:42:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our wireless stress tests are running OOM (on 8GB RAM system)
after a few days.  I turned on kmemleak, and see this, among
others..

Kernel is hacked 3.14.5+ kernel, but we don't have many changes
in the ipv6 code, at least.

Anyone seen similar?

[root@ct521-2n-4255 ~]# cat /debug/kmemleak
unreferenced object 0xffff8802008f8c00 (size 1024):
  comm "softirq", pid 0, jiffies 4294932288 (age 1574.522s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 b0 d7 17 a0 ff ff ff ff  ................
    40 f5 f1 05 02 88 ff ff e0 8c fe ff 00 00 00 00  @...............
  backtrace:
    [<ffffffff815c8be0>] kmemleak_alloc+0x6e/0x93
    [<ffffffff8118eabe>] slab_post_alloc_hook+0x28/0x2a
    [<ffffffff81190aa7>] __kmalloc+0xef/0x12f
    [<ffffffff81526fac>] kzalloc+0xf/0x11
    [<ffffffff815298b2>] __neigh_create+0x68/0x561
    [<ffffffffa0147766>] ip6_finish_output2+0x233/0x3d8 [ipv6]
    [<ffffffffa01499ef>] ip6_finish_output+0x6e/0x73 [ipv6]
    [<ffffffffa0149a70>] ip6_output+0x7c/0xa8 [ipv6]
    [<ffffffffa015a67b>] dst_output+0x18/0x1c [ipv6]
    [<ffffffffa015a8e9>] ndisc_send_skb+0x1dc/0x2b4 [ipv6]
    [<ffffffffa015bb29>] ndisc_send_rs+0xd0/0xe5 [ipv6]
    [<ffffffffa014f43c>] addrconf_dad_completed+0x167/0x1ed [ipv6]
    [<ffffffffa014f6e3>] addrconf_dad_work+0x221/0x2bb [ipv6]
    [<ffffffff810d7b9e>] process_one_work+0x1cb/0x2ee
    [<ffffffff810d8095>] worker_thread+0x12f/0x1fc
    [<ffffffff810dd34d>] kthread+0xc4/0xcc


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
