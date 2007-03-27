From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: APIC error on 32-bit kernel
Date: Tue, 27 Mar 2007 17:49:25 -0500
Message-ID: <20070327174925.5cefb091@osprey.hogchain.net>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
	<m14po6xvtf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf22aec.mail.bellsouth.net ([205.152.59.70]:34983 "EHLO
	imf22aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934294AbXC0Wua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 18:50:30 -0400
Received: from ibm67aec.bellsouth.net ([74.227.37.118])
          by imf22aec.mail.bellsouth.net with ESMTP
          id <20070327224927.HFFD9568.imf22aec.mail.bellsouth.net@ibm67aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 18:49:27 -0400
In-Reply-To: <m14po6xvtf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Mar 2007 14:42:20 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

Thanks for replying, Eric.  I've added atl1-devel to the cc list.

> Do you have msi's working in 2.6.21-rc4 in the x86_64 kernel?

I can't personally verify it anymore because I removed x86_64 to
duplicate the MSI problem on i386, but the driver was working fine under
x86_64 in earlier versions of 2.6.21-rcX.  The first hint of a problem
was a report on March 12 by a user running a 32-bit 2.6.19 Fedora 6
kernel who encountered a kernel panic on network startup.

> > We also do not see this problem on Intel-based motherboards, with
> > either 32- or 64-bit kernels.
> 
> Can you confirm MSI is enabled in those kernels as well?

Absolutely, yes.  MSI is enabled and working for me on a 64-bit
kernel on an Intel-based motherboard, and Luca Tettamanti reports no
problems running a 32-bit kernel on a similar motherboard.  (Luca wrote
the MSI patch for the atl1 driver.)

We enable MSI by default in the driver.

I can now stimulate a kernel oops by pinging my router.  Here's the
console output.

...snip (nothing but a flood of APIC errors above here)...
[  103.052000] APIC error on CPU1: 08(08)
[  103.052000] APIC error on CPU0: 08(08)
[  103.154000] APIC error on CPU1: 08(08)
[  103.154000] APIC error on CPU0: 08(08)
[  103.256000] APIC error on CPU1: 08(08)
[  103.256000] APIC error on CPU0: 08(08)
[  103.359000] APIC error on CPU1: 08(08)
[  103.359000] APIC error on CPU0: 08(08)
[  103.461000] APIC error on CPU1: 08(08)
[  103.461000] APIC error on CPU0: 08(08)

pinged router somewhere about here...

[  103.564000] BUG: unable to handle kernel NULL pointer
dereference<1>BUG: unable to 0
[  103.564000]  printing eip:
[  103.564000] 00000000
[  103.564000] *pde = 00000000
[  103.564000] Oops: 0000 [#1]
[  103.564000] SMP 
[  103.564000] Modules linked in: nf_conntrack_netbios_ns ipt_REJECT
nf_conntrack_ipv4d 
[  103.564000] CPU:    1
[  103.564000] EIP:    0060:[<00000000>]    Not tainted VLI
[  103.564000] EFLAGS: 00010006   (2.6.21-rc5-git1 #1)
[  103.564000] EIP is at 0x0
[  103.564000] eax: 000000a0   ebx: f7d93f58   ecx: c07bb000   edx:
c074de00
[  103.564000] esi: 000000a0   edi: 00000000   ebp: 00000000
esp: c07bbffc 
[  103.564000] ds: 007b   es: 007b   fs: 00d8  gs: 0000 ss: 0068
[  103.564000] Process swapper (pid: 0, ti=c07bb000 task=f7d0e030
task.ti=f7d93000)
[  103.564000] Stack: c040704b 
[  103.564000] Call Trace:
[  103.564000]  [<c040704b>] do_IRQ+0xac/0xd1
[  103.564000]  [<c040580e>] common_interrupt+0x2e/0x34
[  103.564000]  [<c0403c74>] default_idle+0x3d/0x54
[  103.564000]  [<c040339b>] cpu_idle+0xa3/0xbc
[  103.564000]  =======================
[  103.564000] Code:  Bad EIP value.
[  103.564000] EIP: [<00000000>] 0x0 SS:ESP 0068:c07bbffc
[  103.564000] Kernel panic - not syncing: Fatal exception in interrupt
[  103.564000] BUG: at arch/i386/kernel/smp.c:546 smp_call_function()
[  103.564000]  [<c0417b4f>] smp_call_function+0x5c/0xc8
[  103.564000]  [<c054052e>] do_unblank_screen+0x2a/0x120
[  103.564000]  [<c0417bd6>] smp_send_stop+0x1b/0x2e
[  103.564000]  [<c04271ca>] panic+0x54/0xf2
[  103.564000]  [<c04062c5>] die+0x1f8/0x22c
[  103.564000]  [<c0623d13>] do_page_fault+0x40c/0x4df
[  103.564000]  [<c0623907>] do_page_fault+0x0/0x4df
[  103.564000]  [<c0622574>] error_code+0x7c/0x84
[  103.564000]  [<c040704b>] do_IRQ+0xac/0xd1
[  103.564000]  [<c040580e>] common_interrupt+0x2e/0x34
[  103.564000]  [<c0403c74>] default_idle+0x3d/0x54
[  103.564000]  [<c040339b>] cpu_idle+0xa3/0xbc
[  103.564000]  =======================
[  103.564000]  at virtual address 00000000
[  103.564000]  printing eip:
[  103.564000] 00000000
[  103.564000] *pde = 1f8f6067
[  103.564000] Oops: 0000 [#2]
[  103.564000] SMP 
[  103.564000] Modules linked in: nf_conntrack_netbios_ns ipt_REJECT
nf_conntrack_ipv4d
[  103.564000] CPU:    0
[  103.564000] EIP:    0060:[<00000000>]    Not tainted VLI
[  103.564000] EFLAGS: 00010087   (2.6.21-rc5-git1 #1)
[  103.564000] EIP is at 0x0
[  103.564000] eax: 000000a0   ebx: c0753f74   ecx: c07ba000   edx:
c074de00
[  103.564000] esi: 000000a0   edi: 00000000   ebp: 00000000 esp:
c07baffc
[  103.564000] ds: 007b   es: 007b   fs: 00d8  gs: 0000 ss: 0068
[  103.564000] Process swapper (pid: 0, ti=c07ba000 task=c07094c0
task.ti=c0753000)
[  103.564000] Stack: c040704b 
[  103.564000] Call Trace:
[  103.564000]  [<c040704b>] do_IRQ+0xac/0xd1
[  103.564000]  [<c040580e>] common_interrupt+0x2e/0x34
[  103.564000]  [<c0403c74>] default_idle+0x3d/0x54
[  103.564000]  [<c040339b>] cpu_idle+0xa3/0xbc
[  103.564000]  [<c0758a37>] start_kernel+0x45d/0x465
[  103.564000]  [<c07581ae>] unknown_bootoption+0x0/0x202
[  103.564000]  =======================
[  103.564000] Code:  Bad EIP value.
[  103.564000] EIP: [<00000000>] 0x0 SS:ESP 0068:c07baffc
[  103.564000] Kernel panic - not syncing: Fatal exception in interrupt

After a few seconds, machine spontaneously reboots.
