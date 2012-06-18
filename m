From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: divide by 0 error in igbvf_set_coalesce - ab50a2a
Date: Mon, 18 Jun 2012 20:45:56 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D15B30910@FMSMSX107.amr.corp.intel.com>
References: <4FDF706D.7080509@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <daahern@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5736 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab2FRUp6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:45:58 -0400
In-Reply-To: <4FDF706D.7080509@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Ahern [mailto:daahern@cisco.com]
> Sent: Monday, June 18, 2012 11:16 AM
> To: Williams, Mitch A
> Cc: netdev@vger.kernel.org
> Subject: divide by 0 error in igbvf_set_coalesce - ab50a2a
> 
> Mitch:
> 
> I have a VM using a 82576 based VF. Running:
> $ ethtool -C eth2 rx-usecs 0
> 
> generates the following trace on console:
> 
> [  894.683322] divide error: 0000 [#1] SMP [  894.684020] CPU 1 [

Thanks for letting me know, David. I'll look into it and get a patch out soon. Shouldn't be that big of a deal to fix.

In the meantime, my advice to you is, "Don't do that."

-Mitch



> 894.684020] Modules linked in: sunrpc virtio_net igbvf virtio_blk
> virtio_pci virtio_ring virtio [  894.684020] [  894.684020] Pid: 7310,
> comm: ethtool Not tainted 3.5.0-rc1 #0 Bochs Bochs [  894.684020] RIP:
> 0010:[<ffffffffa00259ec>]  [<ffffffffa00259ec>]
> igbvf_set_coalesce+0x5b/0x8b [igbvf] [  894.684020] RSP:
> 0018:ffff88003cd51c38  EFLAGS: 00010246 [  894.684020] RAX:
> 000000003b9aca00 RBX: ffff88003aa42000 RCX:
> 0000000000000000
> [  894.684020] RDX: 0000000000000000 RSI: ffff88003cd51c48 RDI:
> ffff88003aa42780
> [  894.684020] RBP: ffff88003cd51c38 R08: 0000000000000000 R09:
> 0000000000000000
> [  894.684020] R10: 0000000000000000 R11: ffff88003cd51ec8 R12:
> ffff88003cd51c48
> [  894.684020] R13: 000000000000000f R14: 00000000ffffffff R15:
> 00000000fffffff2
> [  894.684020] FS:  00007f8142ccb720(0000) GS:ffff88003fd00000(0000)
> knlGS:0000000000000000
> [  894.684020] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 [
> 894.684020] CR2: 000000000040466c CR3: 000000003c754000 CR4:
> 00000000000007e0
> [  894.684020] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  894.684020] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  894.684020] Process ethtool (pid: 7310, threadinfo ffff88003cd50000,
> task ffff88003b984470) [  894.684020] Stack:
> [  894.684020]  ffff88003cd51cb8 ffffffff8132bcf5 000000000000000f
> 0000000000000000
> [  894.684020]  0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  894.684020]  0000000000000000 0000000000000000 0000000000000000
> 0000000000000000
> [  894.684020] Call Trace:
> [  894.684020]  [<ffffffff8132bcf5>] ethtool_set_coalesce+0x54/0x5d [
> 894.684020]  [<ffffffff8132d0c9>] dev_ethtool+0x5dc/0x175b [
> 894.684020]  [<ffffffff81057921>] ? need_resched+0x1e/0x28 [
> 894.684020]  [<ffffffff81057934>] ? should_resched+0x9/0x29 [
> 894.684020]  [<ffffffff813be822>] ? _cond_resched+0xe/0x22 [
> 894.684020]  [<ffffffff8132b227>] dev_ioctl+0x517/0x684 [  894.684020]
> [<ffffffff810ec91f>] ? pmd_offset+0x14/0x3b [  894.684020]
> [<ffffffff81315045>] sock_do_ioctl+0x3d/0x48 [  894.684020]
> [<ffffffff8131545f>] sock_ioctl+0x1f8/0x207 [  894.684020]
> [<ffffffff8111f6fa>] do_vfs_ioctl+0x475/0x4b6 [  894.684020]
> [<ffffffff811f8e70>] ?
> inode_has_perm.clone.19.clone.27+0x33/0x35
> [  894.684020]  [<ffffffff811f9298>] ? file_has_perm+0x73/0x7e [
> 894.684020]  [<ffffffff8110f6cf>] ? fd_install+0x57/0x60 [  894.684020]
> [<ffffffff8111f791>] sys_ioctl+0x56/0x79 [  894.684020]
> [<ffffffff813c5de9>] system_call_fastpath+0x16/0x1b [  894.684020] Code:
> 83 f8 02 77 0f c7 87 0c 03 00 00 e8 01 00 00 8b 46
> 04 eb 19 8d 04 8d 00 00 00 00 31 d2 89 87 0c 03 00 00 c1 e1 0a b8 00 ca
> 9a 3b <f7> f1 89 87 08 03 00 00 8b 97 0c 03 00 00 48 8b 87 80 03 00 00 [
> 894.684020] RIP  [<ffffffffa00259ec>] igbvf_set_coalesce+0x5b/0x8b
> [igbvf] [  894.684020]  RSP <ffff88003cd51c38> [  894.779474] ---[ end
> trace 162bed6b66df758d ]---
> 
> 
> This commit introduced the problem:
> 
> commit ab50a2a430693b0961dc7b7d9fe2a4bd77d11ea6
> Author: Mitch A Williams <mitch.a.williams@intel.com>
> Date:   Sat Jan 14 08:10:50 2012 +0000
> 
>      igbvf: refactor Interrupt Throttle Rate code
> 
> David
