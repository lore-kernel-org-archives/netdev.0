From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: broken PCNET32 in 2.6.24 requires experimental PCNET32_NAPI?
Date: Fri, 19 Oct 2007 00:33:09 -0400
Message-ID: <200710190433.l9J4X9vh011890@agora.fsl.cs.sunysb.edu>
References: <4717C90A.4060208@garzik.org>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, linux-kernel@vger.kernel.org,
	pcnet32@verizon.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:57633 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbXJSEdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 00:33:22 -0400
In-reply-to: Your message of "Thu, 18 Oct 2007 16:58:50 EDT."
             <4717C90A.4060208@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <4717C90A.4060208@garzik.org>, Jeff Garzik writes:
> Erez Zadok wrote:
> > I'm using Linus's git tree as of commit
> > d85714d81cc0408daddb68c10f7fd69eafe7c213.  I built that kernel under vmware
> > workstation 6.0.1 which emulates a pcnet32 nic.  When I only turn on
> > CONFIG_PCNET32, my network interface doesn't seem to come up fully: my dhcp
> > server sees a request, offers an IP addr, but the VM running 2.6.24 doesn't
> > pick up the response.  Manually configuring the eth0 and pinging yields
> > similar results: no replies come back.  The same VM has lots of other
> > kernels on it, all of which work fine (so it's not an iptables/selinux
> > problem, or the like).
> > 
> > If, however, I turn on the EXPERIMENTAL feature CONFIG_PCNET32_NAPI, then
> > the driver works again.  So, is this NAPI feature now a required one or did
> > the base driver somehow got broken?  I've not investigated this further.
> 
> Fixes were posted by the maintainer, and pushed to Linus, yesterday...
> 
> 	Jeff

Thanks.  Now, with more patches that Linus committed, I get a different oops
when I try to configure the interface (ifup eth0).  I'm using:

CONFIG_PCNET32=m

And I tried with and without CONFIG_PCNET32_NAPI.

Cheers,
Erez.

------------------------------------------------------------------------------

pcnet32: PCnet/PCI II 79C970A at 0x1080, 00 0c 29 f0 e5 15 assigned IRQ 9.
eth0: registered as PCnet/PCI II 79C970A
pcnet32: 1 cards_found.
EXT3 FS on hda1, internal journal
Adding 522104k swap on /dev/hda2.  Priority:-1 extents:1 across:522104k
eth0: link up
BUG: unable to handle kernel NULL pointer dereference at virtual address
00000004
printing eip: c022f03d *pde = 00000000 
Oops: 0000 [#1] DEBUG_PAGEALLOC
Modules linked in: pcnet32
CPU:    0
EIP:    0060:[<c022f03d>]    Not tainted VLI
EFLAGS: 00010246   (2.6.23-unionfs2-2.6.24-rc0-pre #7)
EIP is at sk_filter_delayed_uncharge+0x1/0x22
eax: c1d21bf0   ebx: 00000000   ecx: c022f1a7   edx: 00000000
esi: c1ffdf70   edi: c1d21bf0   ebp: c3e13f04   esp: c3e13ed4
ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
Process dhclient (pid: 1221, ti=c3e12000 task=c1edf5b0 task.ti=c3e12000)
Stack: c3e13f04 c022f1ff 00000002 00000001 c022f1a7 00000068 c1ffdf80
00000058 
       00000000 c1d21bf0 c3e13f2c c4435d90 c3e13f50 c021ea1b c17a08e0
c3d121c0 
       36947065 c3d8ae28 0000001a 0000000b 0000000b c1ff0800 0000000b
80070600 
Call Trace:
 [<c0102bc2>] show_trace_log_lvl+0x1a/0x2f
 [<c0102c72>] show_stack_log_lvl+0x9b/0xa3
 [<c0102e2e>] show_registers+0x1b4/0x285
 [<c0102fff>] die+0x100/0x21d
 [<c010a72f>] do_page_fault+0x434/0x515
 [<c026a40a>] error_code+0x6a/0x70
 [<c021ea1b>] sock_setsockopt+0x43f/0x494
 [<c021b994>] sys_setsockopt+0x4f/0x85
 [<c021ce0e>] sys_socketcall+0x1cb/0x222
 [<c0102586>] sysenter_past_esp+0x5f/0x91
 =======================
Code: 18 01 39 d0 7d 19 43 4e 39 d3 0f 8c 3d fe ff ff 0f b7 44 d1 f8 31 d2
83 e0 
07 83 f8 06 74 05 ba ea ff ff ff 5b 89 d0 5e 5d c3 55 <8b> 4a 04 89 e5 8d 0c
cd 1
0 00 00 00 29 88 b8 00 00 00 8d 42 08 
EIP: [<c022f03d>] sk_filter_delayed_uncharge+0x1/0x22 SS:ESP 0068:c3e13ed4

------------------------------------------------------------------------------
