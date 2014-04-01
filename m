From: Dave <dave@0bits.com>
Subject: crash in 3.14 kernel in ip tunnel
Date: Tue, 1 Apr 2014 03:56:13 +0000 (UTC)
Message-ID: <loom.20140401T055418-167@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:39246 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbaDAEAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 00:00:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1WUpro-0007zr-Aj
	for netdev@vger.kernel.org; Tue, 01 Apr 2014 06:00:05 +0200
Received: from 2e1c35aa.lon.100tb.com ([2e1c35aa.lon.100tb.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 06:00:04 +0200
Received: from dave by 2e1c35aa.lon.100tb.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 06:00:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reproduceable crash when bringing up my ip tunnel in 3.14 kernel


[   39.584399] ipip: IPv4 over IPv4 tunneling driver
[   39.586552] BUG: using smp_processor_id() in preemptible [00000000] code:
ip/1311
[   39.586658] caller is tunnel_dst_set.isra.29+0xd/0x40 [ip_tunnel]
[   39.586737] CPU: 0 PID: 1311 Comm: ip Not tainted 3.14.0 #2
[   39.586808] Hardware name:    / , BIOS 080016  09/28/2011
[   39.586874]  0000000000019de8 ffffffff814423a2 0000000000000000
ffffffff811fae39
[   39.587093]  ffff8800bb11f0c0 ffffffffa0513f4d ffff8800ba662000
ffff8800ba6ec000
[   39.587285]  ffffffffa051407f 0000000100000009 0004000000000000
85c5615c00000000
[   39.587461] Call Trace:
[   39.587530]  [<ffffffff814423a2>] ? dump_stack+0x4a/0x75
[   39.587605]  [<ffffffff811fae39>] ? debug_smp_processor_id+0xc9/0xe0
[   39.587690]  [<ffffffffa0513f4d>] ? tunnel_dst_set.isra.29+0xd/0x40
[ip_tunnel]
[   39.587772]  [<ffffffffa051407f>] ? ip_tunnel_bind_dev+0xff/0x170 [ip_tunnel]
[   39.587855]  [<ffffffffa0514f52>] ? ip_tunnel_ioctl+0x272/0x370 [ip_tunnel]
[   39.587937]  [<ffffffffa051e416>] ? ipip_tunnel_ioctl+0xa6/0xf0 [ipip]
[   39.588052]  [<ffffffff813c0e4c>] ? dev_ifsioc+0x30c/0x350
[   39.588130]  [<ffffffff813c1219>] ? dev_ioctl+0x2f9/0x590
[   39.588211]  [<ffffffff810dd969>] ? kmem_cache_alloc+0x39/0xd0
[   39.588280]  [<ffffffff8139589e>] ? sock_ioctl+0x11e/0x2b0
[   39.588346]  [<ffffffff810e2d38>] ? get_empty_filp+0xa8/0x160
[   39.588418]  [<ffffffff810f1d18>] ? do_vfs_ioctl+0x2d8/0x4c0
[   39.588492]  [<ffffffff8139560b>] ? sock_alloc_file+0x9b/0x130
[   39.588564]  [<ffffffff8144771e>] ? _raw_spin_lock+0xe/0x30
[   39.588637]  [<ffffffff810f1f3a>] ? SyS_ioctl+0x3a/0x80
[   39.588711]  [<ffffffff81398146>] ? SyS_socket+0x66/0xa0
[   39.588789]  [<ffffffff81448662>] ? system_call_fastpath+0x16/0x1b
[   39.795279] NET: Registered protocol family 5
