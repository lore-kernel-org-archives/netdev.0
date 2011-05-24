From: Stephen Hemminger <shemminger@vyatta.com>
Subject: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 07:41:56 -0700
Message-ID: <20110524074156.58eb30f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36712 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab1EXOl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 10:41:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Got this bug report against 2.6.39.  Looks like ip_fragment() is now
getting confused when called from bridge netfilter. Probably related to
the changes to do ip_options_compile for the bridge input path.

https://bugzilla.kernel.org/show_bug.cgi?id=35672

May 23 02:04:24 lxc kernel: [99498.329036] BUG: unable to handle kernel NULL
pointer dereference at 00000004
May 23 02:04:24 lxc kernel: [99498.330017] IP: [<c143d6bf>] dst_mtu+0xb/0x1c
May 23 02:04:24 lxc kernel: [99498.330017] *pdpt = 000000001fb55001 *pde =
0000000000000000
May 23 02:04:24 lxc kernel: [99498.330017] Oops: 0000 [#1] SMP
May 23 02:04:24 lxc kernel: [99498.330017] last sysfs file:
/sys/devices/virtual/vc/vcsa8/uevent
May 23 02:04:24 lxc kernel: [99498.330017] Modules linked in: lp ppdev
parport_pc parport fuse firewire_ohci firewire_core crc_itu_t intel_agp
intel_gtt
May 23 02:04:24 lxc kernel: [99498.330017]
May 23 02:04:24 lxc kernel: [99498.330017] Pid: 0, comm: swapper Not tainted
2.6.39-lxc #2 .   .  /IP35 Pro XE(Intel P35-ICH9R)
May 23 02:04:24 lxc kernel: [99498.330017] EIP: 0060:[<c143d6bf>] EFLAGS:
00010246 CPU: 0
May 23 02:04:24 lxc kernel: [99498.330017] EIP is at dst_mtu+0xb/0x1c
May 23 02:04:24 lxc kernel: [99498.330017] EAX: 00000000 EBX: e90b6b40 ECX:
effc981c EDX: effc9000
May 23 02:04:24 lxc kernel: [99498.330017] ESI: c1a0d84e EDI: dda6331e EBP:
f080bb44 ESP: f080bb44
May 23 02:04:24 lxc kernel: [99498.330017]  DS: 007b ES: 007b FS: 00d8 GS: 0000
SS: 0068
May 23 02:04:24 lxc kernel: [99498.330017] Process swapper (pid: 0, ti=f080a000
task=c172b7e0 task.ti=c1724000)
May 23 02:04:24 lxc kernel: [99498.330017] Stack:
May 23 02:04:24 lxc kernel: [99498.330017]  f080bb8c c143e20d 00000004 f080bb88
c141aab2 c14b46db effc9000 00000014
May 23 02:04:24 lxc kernel: [99498.330017]  c14b8a44 effc9000 e90b6b40 00000014
effc981c e90b6b58 cd472800 e90b6b40
May 23 02:04:24 lxc kernel: [99498.330017]  c14b8a44 dda6331e f080bb98 c14b8aa0
e90b6b40 f080bba8 c14b881a e90b6b40
May 23 02:04:24 lxc kernel: [99498.330017] Call Trace:
May 23 02:04:24 lxc kernel: [99498.330017]  [<c143e20d>] ip_fragment+0xb5/0x66c
May 23 02:04:24 lxc kernel: [99498.330017]  [<c141aab2>] ?
nf_hook_slow+0x43/0xd1
May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b46db>] ? br_flood+0x83/0x83
May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8a44>] ?
br_parse_ip_options+0x1b0/0x1b0
May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8a44>] ?
br_parse_ip_options+0x1b0/0x1b0
May 23 02:04:24 lxc kernel: [99498.330017]  [<c14b8aa0>]
br_nf_dev_queue_xmit+0x5c/0x68
