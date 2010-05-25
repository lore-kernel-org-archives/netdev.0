From: Anton Blanchard <anton@samba.org>
Subject: Warning in net/ipv4/af_inet.c:154
Date: Tue, 25 May 2010 21:58:14 +1000
Message-ID: <20100525115813.GA28063@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46756 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754245Ab0EYMAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 08:00:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

A build from last night (2.6.34-git9) is hitting the following WARN_ON on
a ppc64 box:

Badness at net/ipv4/af_inet.c:154

NIP [c00000000062b034] .inet_sock_destruct+0x1b0/0x1f0
LR [c0000000005b376c] .__sk_free+0x58/0x154
Call Trace:
[c000000000088c0c] .__local_bh_disable+0xdc/0xfc (unreliable)
[c0000000005b376c] .__sk_free+0x58/0x154
[c0000000005b3978] .sk_free+0x4c/0x60
[c0000000005b3ab4] .sk_common_release+0x128/0x148
[c00000000061da44] .udp_lib_close+0x28/0x40
[c00000000062a990] .inet_release+0xd0/0xf8
[c0000000005adbf8] .sock_release+0x60/0xec
[c0000000005adcd0] .sock_close+0x4c/0x6c
[c000000000186554] .__fput+0x184/0x270
[c00000000018668c] .fput+0x4c/0x60
[c000000000182248] .filp_close+0xc8/0xf4
[c0000000000826d4] .put_files_struct+0xc8/0x158
[c0000000000827d4] .exit_files+0x70/0x8c
[c0000000000848cc] .do_exit+0x2c8/0x82c
[c000000000084efc] .do_group_exit+0xcc/0x100
[c000000000084f5c] .SyS_exit_group+0x2c/0x48
[c000000000008554] syscall_exit+0x0/0x40

Which is:

        WARN_ON(sk->sk_forward_alloc);

Anton
