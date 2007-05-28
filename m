From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: EIP is at netlink_insert+0x41/0x10c
Date: Sun, 27 May 2007 23:52:34 -0700
Message-ID: <20070527235234.fe2d4dab.akpm@linux-foundation.org>
References: <a44ae5cd0705272347x5e37d4aeg1f6ac8ece0e1542c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Miles Lane" <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:57174 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbXE1GxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 02:53:03 -0400
In-Reply-To: <a44ae5cd0705272347x5e37d4aeg1f6ac8ece0e1542c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 May 2007 23:47:52 -0700 "Miles Lane" <miles.lane@gmail.com> wrote:
>

please cc netdev@vger.kernel.org on net-related matters.

> Linux version 2.6.22-rc2-mm1 (root@heliotrope.localdomain) (gcc
> version 4.1.2 20070502 (Red Hat 4.1.2-12)) #1 PREEMPT Sun May 27
> 18:30:28 PDT 2007
>
> ...
>
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mice: PS/2 mouse device common for all mice
> i2c-adapter i2c-0: nForce2 SMBus adapter at 0x5000
> i2c-adapter i2c-1: nForce2 SMBus adapter at 0x5500
> usbcore: registered new interface driver usbhid
> drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
> oprofile: using NMI interrupt.
> TCP cubic registered
> NET: Registered protocol family 1
> NET: Registered protocol family 10
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> powernow-k8: Processor cpuid 6a0 not supported
> Using IPI Shortcut mode
> Freeing unused kernel memory: 260k freed
> Write protecting the kernel text: 3108k
> Write protecting the kernel read-only data: 1699k
> input: AT Translated Set 2 keyboard as /class/input/input2
> BUG: unable to handle kernel paging request at virtual address 7272746d
>  printing eip:
> c038fb7f
> *pde = 00000000
> Oops: 0000 [#1]
> PREEMPT
> Modules linked in:
> CPU:    0
> EIP:    0060:[<c038fb7f>]    Not tainted VLI
> EFLAGS: 00210002   (2.6.22-rc2-mm1 #1)
> EIP is at netlink_insert+0x41/0x10c
> eax: c201a100   ebx: c242e3c0   ecx: 59bdb910   edx: 7272746d
> esi: c2060348   edi: c2ae2c00   ebp: c2af3ebc   esp: c2af3ea0
> ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
> Process init (pid: 505, ti=c2af3000 task=c2186150 task.ti=c2af3000)
> Stack: 00000020 000001f9 c201a100 00000000 c242e3c0 c2ae2c00 c2af3ee0 c2af3ed8
>        c03910dd c242e3c0 c2af3ee0 c0431fe0 c242e3c0 c2af3ee0 c2af3f74 c0378d48
>        00000010 000001f9 ffffffff c218c2f4 48305000 00000000 00000000 c2af5ac0
> Call Trace:
>  [<c03910dd>] netlink_bind+0x86/0x12d
>  [<c0378d48>] sys_bind+0x4e/0x6d
>  [<c037a008>] sys_socketcall+0x72/0x222
>  [<c0103e16>] sysenter_past_esp+0x5f/0x99
>  [<ffffe410>] 0xffffe410
>  =======================
> INFO: lockdep is turned off.
> Code: 35 ec aa 8a c0 e8 c4 fd ff ff 8b 55 e8 89 f0 e8 80 f6 ff ff 89
> 45 ec 8b 10 c7 45 f0 00 00 00 00 eb 05 ff 45 f0 89 c2 85 d2 74 1b <8b>
> 02 0f 18 00 90 8b 4d e8 39 8a 70 02 00 00 75 e6 bb 9e ff ff
> EIP: [<c038fb7f>] netlink_insert+0x41/0x10c SS:ESP 0068:c2af3ea0
> note: init[505] exited with preempt_count 1

I wonder how /bin/init got to run netlink stuff.

