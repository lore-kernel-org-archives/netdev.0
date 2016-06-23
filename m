From: Dave Jones <davej@codemonkey.org.uk>
Subject: [4.6] kernel BUG at net/ipv6/raw.c:592
Date: Thu, 23 Jun 2016 13:23:15 -0400
Message-ID: <20160623172315.GA27624@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:54512 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcFWRXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 13:23:17 -0400
Received: from c-65-96-118-216.hsd1.ma.comcast.net ([65.96.118.216] helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.87)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1bG8LU-00074z-4z
	for netdev@vger.kernel.org; Thu, 23 Jun 2016 18:23:16 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Found this logs after a Trinity run.

kernel BUG at net/ipv6/raw.c:592!
------------[ cut here ]------------
invalid opcode: 0000 [#1] SMP 

Modules linked in: udp_diag dccp_ipv6 dccp_ipv4 dccp sctp af_key tcp_diag inet_diag ip6table_filter xt_NFLOG nfnetlink_log xt_comment xt_statistic iptable_filter nfsv3 nfs_acl nfs fscache lockd grace autofs4 i2c_piix4 rpcsec_gss_krb5 auth_rpcgss oid_registry sunrpc loop dummy ipmi_devintf iTCO_wdt iTCO_vendor_support acpi_cpufreq efivars ipmi_si ipmi_msghandler i2c_i801 i2c_core sg lpc_ich mfd_core button

CPU: 2 PID: 28854 Comm: trinity-c23 Not tainted 4.6.0 #1
Hardware name: Quanta Leopard-DDR3/Leopard-DDR3, BIOS F06_3A14.DDR3 05/13/2015
task: ffff880459cab600 ti: ffff880747bc4000 task.ti: ffff880747bc4000
RIP: 0010:[<ffffffff817515e0>] [<ffffffff817515e0>] rawv6_sendmsg+0xc30/0xc40
RSP: 0018:ffff880747bc7bf8  EFLAGS: 00010282
RAX: 00000000fffffff2 RBX: ffff88080c6f2d00 RCX: 0000000000000002
RDX: ffff880747bc7cd8 RSI: 0000000000000030 RDI: ffff8803de801500
RBP: ffff880747bc7d90 R08: 000000000000002d R09: 0000000000000009
R10: ffff8803de801500 R11: 0000000000000009 R12: 0000000000000030
R13: ffff8803de801500 R14: ffff88086d67e000 R15: ffff88046bdac480
FS:  00007fe29c566700(0000) GS:ffff88046fa40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000001f0f2c0 CR3: 000000080b99d000 CR4: 00000000001406e0
Stack:
 ffffffff00000000 ffff88086d67e000 ffff880747bc7d18 ffff88046bdac480
 ffff880400000000 0000000000000000 ffff880747bc7c68 ffff88086d67e000
 ffff88080000002d ffff880800000009 0000000000000000 0000000000000001
 
Call Trace:
 [<ffffffff8177f642>] ? page_fault+0x22/0x30
 [<ffffffff81781f00>] ? bad_to_user+0x6a/0x6fa
 [<ffffffff816fe7b7>] inet_sendmsg+0x67/0xa0
 [<ffffffff816673e8>] sock_sendmsg+0x38/0x50
 [<ffffffff81667478>] sock_write_iter+0x78/0xd0
 [<ffffffff811cc97a>] __vfs_write+0xaa/0xe0
 [<ffffffff811cd7c2>] vfs_write+0xa2/0x1a0
 [<ffffffff811ceb06>] SyS_write+0x46/0xa0 
 [<ffffffff8177da5b>] entry_SYSCALL_64_fastpath+0x13/0x8f
Code: 23 f7 ff ff f7 d0 41 01 c0 41 83 d0 00 e9 ac fd ff ff 48 8b 44 24 48 48 8b 80 c0 01 00 00 65 48 ff 40 28 8b 51 78 d0 41 01 c0 41 83 d0 00 e9 ac fd ff ff 48 8b 44 24 48 48 8b 80 c0 01 00 00 65 48 ff 40 28 8b 51 78 e9 64 fe ff ff <0f> 0b 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 

RIP [<ffffffff817515e0>] rawv6_sendmsg+0xc30/0xc40
 RSP <ffff880747bc7bf8>

 590 
 591         offset += skb_transport_offset(skb);
 592         BUG_ON(skb_copy_bits(skb, offset, &csum, 2));
 593 
