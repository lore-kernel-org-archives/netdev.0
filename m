From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference - linux-2.6.22
Date: Fri, 24 Aug 2007 01:40:56 +0200
Message-ID: <6bffcb0e0708231640m7d76d1e0uac8f1f573af84aea@mail.gmail.com>
References: <200708210256.58818.rc.poison@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: poison <rc.poison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:30998 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763528AbXHWXk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 19:40:58 -0400
Received: by rv-out-0910.google.com with SMTP id k20so513970rvb
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 16:40:57 -0700 (PDT)
In-Reply-To: <200708210256.58818.rc.poison@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Adding netdev to CC]

On 21/08/07, poison <rc.poison@gmail.com> wrote:
> Hello,
> after running a few instances of bittorent-curses on 2.6.22 - 2.6.22.3 it
> takes about 15min to 2hrs for my System to hang. 2.6.21.7 is definately fine,
> 2.6.21 probably (ran for 4hrs without hanging).
> If I'm lucky the Oops below makes it to my syslog (unfortunately SysRq-{p,s,i}
> doesn't work when it hangs, neither can I ssh into it):
>
> Aug 18 19:47:41 draco kernel: BUG: unable to handle kernel NULL pointer
> dereference at virtual address 00000000
> Aug 18 19:47:41 draco kernel:  printing eip:
> Aug 18 19:47:41 draco kernel: c038fcba
> Aug 18 19:47:41 draco kernel: *pdpt = 0000000033830001
> Aug 18 19:47:41 draco kernel: *pde = 0000000000000000
> Aug 18 19:47:41 draco kernel: Oops: 0002 [#1]
> Aug 18 19:47:41 draco kernel: SMP
> Aug 18 19:47:41 draco kernel: Modules linked in: snd_hda_intel snd_emu10k1
> cls_u32 sch_sfq sch_htb snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> snd_pcm_oss snd_mixer_oss rfcomm hidp l2cap nfsd exportfs lockd sunrpc
> coretemp hwmon eeprom snd_rawmidi snd_ac97_codec hci_usb ac97_bus
> snd_seq_device snd_util_mem snd_pcm bluetooth snd_hwdep snd_timer snd
> snd_page_alloc i2c_i801 emu10k1_gp gameport i2c_core sg
> Aug 18 19:47:41 draco kernel: CPU:    0
> Aug 18 19:47:41 draco kernel: EIP:    0060:[<c038fcba>]    Not tainted VLI
> Aug 18 19:47:41 draco kernel: EFLAGS: 00210202   (2.6.22.2poison #14)
> Aug 18 19:47:41 draco kernel: EIP is at tcp_sendmsg+0x40a/0xb70
> Aug 18 19:47:41 draco kernel: eax: 00000000   ebx: ec5b807c   ecx: c04b43a0
> edx: ec5b807c
> Aug 18 19:47:41 draco kernel: esi: ec5b8000   edi: 00000100   ebp: ec524180
> esp: f3a11d30
> Aug 18 19:47:41 draco kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss:
> 0068
> Aug 18 19:47:41 draco kernel: Process bittorrent-curs (pid: 3974, ti=f3a10000
> task=f3a0e000 task.ti=f3a10000)
> Aug 18 19:47:41 draco kernel: Stack: ffffffff ebe562f5 0000000b 00000000
> f3a11d94 00000000 ec5b807c 00000000
> Aug 18 19:47:41 draco kernel:        00000001 00100100 f3a11f40 00000000
> 00000040 00000200 00000200 000004b6
> Aug 18 19:47:41 draco kernel:        08604707 00200200 f3e5c798 eeaa4b40
> 00000000 f3a0e000 000001f5 00100100
> Aug 18 19:47:41 draco kernel: Call Trace:
> Aug 18 19:47:41 draco kernel:  [<c03ac267>] inet_sendmsg+0x37/0x70
> Aug 18 19:47:41 draco kernel:  [<c03511ef>] sock_sendmsg+0xbf/0xf0
> Aug 18 19:47:41 draco kernel:  [<c012fe60>] autoremove_wake_function+0x0/0x50
> Aug 18 19:47:41 draco kernel:  [<c01188f0>] default_wake_function+0x0/0x10
> Aug 18 19:47:41 draco last message repeated 3 times
> Aug 18 19:47:41 draco kernel:  [<c015589d>] find_extend_vma+0x1d/0x70
> Aug 18 19:47:41 draco kernel:  [<c03515cf>] sys_sendto+0x12f/0x180
> Aug 18 19:47:41 draco kernel:  [<c0139dfc>] futex_wake+0xac/0xd0
> Aug 18 19:47:41 draco kernel:  [<c013a4dd>] do_futex+0x6bd/0xbd0
> Aug 18 19:47:41 draco kernel:  [<c0351653>] sys_send+0x33/0x40
> Aug 18 19:47:41 draco kernel:  [<c03525c2>] sys_socketcall+0x142/0x280
> Aug 18 19:47:41 draco kernel:  [<c0205d20>] copy_to_user+0x30/0x60
> Aug 18 19:47:41 draco kernel:  [<c0102a92>] syscall_call+0x7/0xb
> Aug 18 19:47:41 draco kernel:  =======================
> Aug 18 19:47:41 draco kernel: Code: 85 fb 06 00 00 80 ca 10 8b 83 94 00 00 00
> 88 53 68 f0 81 00 00 00 01 00 8b 44 24 18 ff 40 08 8b 54 24 18 8b 42 04 89 13
> 89 43 04 <89> 18 89 5a 04 8b 8e 2c 01 00 00 85 c9 0f 84 19 06 00 00 8b 83
> Aug 18 19:47:41 draco kernel: EIP: [<c038fcba>] tcp_sendmsg+0x40a/0xb70 SS:ESP
> 0068:f3a11d30
> Aug 18 19:47:51 draco kernel:
> Aug 18 19:47:51 draco kernel: Pid: 3812, comm:                    X
> Aug 18 19:47:51 draco kernel: EIP: 0060:[<c014a4c2>] CPU: 0
> Aug 18 19:47:51 draco kernel: EIP is at __get_free_pages+0x22/0x40
> Aug 18 19:47:51 draco kernel:  EFLAGS: 00003246    Not tainted
> (2.6.22.2poison #14)
> Aug 18 19:47:51 draco kernel: EAX: 000000d0 EBX: 000000d0 ECX: c0496b40 EDX:
> 00000000
> Aug 18 19:47:51 draco kernel: ESI: 00000000 EDI: f5ba1be4 EBP: f49a4d80 DS:
> 007b ES: 007b FS: 00d8
> Aug 18 19:47:51 draco kernel: CR0: 8005003b CR2: b7384000 CR3: 37165000 CR4:
> 000006f0
> Aug 18 19:47:51 draco kernel:  [<c01734b6>] __pollwait+0xa6/0x100
> Aug 18 19:47:51 draco kernel:  [<c03c9597>] unix_poll+0x17/0xa0
> Aug 18 19:47:51 draco kernel:  [<c03500bc>] sock_poll+0xc/0x10
> Aug 18 19:47:51 draco kernel:  [<c0172bec>] do_select+0x25c/0x490
> Aug 18 19:47:51 draco kernel:  [<c0173410>] __pollwait+0x0/0x100
> Aug 18 19:47:51 draco kernel:  [<c01188f0>] default_wake_function+0x0/0x10
> Aug 18 19:47:51 draco last message repeated 19 times
> Aug 18 19:47:51 draco kernel:  [<c0172fe8>] core_sys_select+0x1c8/0x2f0
> Aug 18 19:47:51 draco kernel:  [<c0166a30>] do_readv_writev+0x120/0x190
> Aug 18 19:47:51 draco kernel:  [<c03503c0>] sock_aio_write+0x0/0x110
> Aug 18 19:47:51 draco kernel:  [<c017355d>] sys_select+0x4d/0x1b0
> Aug 18 19:47:51 draco kernel:  [<c0166adc>] vfs_writev+0x3c/0x50
> Aug 18 19:47:51 draco kernel:  [<c0166f97>] sys_writev+0x47/0x80
> Aug 18 19:47:51 draco kernel:  [<c0102a92>] syscall_call+0x7/0xb
> Aug 18 19:47:51 draco kernel:  =======================
> ---
>
> It's also attached together with one from a tainted 2.6.22.3
>
> The error is reproducable for me by running 4 bittorent instances and wating.
> 2.6.22 lives no longer than 2hrs, so when bisecting I assumed it was good
> after 4hrs ... so I may as well have taken a wrong turn. Result here:
>
> 00ed8e3dda47f8421b11da17e353d7db8c878121 is first bad commit
> commit 00ed8e3dda47f8421b11da17e353d7db8c878121
> Author: Dmitriy Monakhov <dmonakhov@sw.ru>
> Date:   Sun Mar 11 15:36:19 2007 +0300
>
>     driver core: fix device_add error path
>
>      - At the moment we jump here device was't added to
>        dev->class->devices list yet.
>
>     Signed-off-by: Monakhov Dmitriy <dmonakhov@openvz.org>
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
>
> :040000 040000 bc29a0e7ec67055b2cad30ef3e0d19b8fe0c0981
> 8b1eee1c34d5b5db827a4d0c8a8363eb827338f3 M      dr
> ivers
> ---
>
> gcc -v
> Reading specs from /usr/lib/gcc/i486-slackware-linux/4.1.2/specs
> Target: i486-slackware-linux
> Configured
> with: ../gcc-4.1.2/configure --prefix=/usr --enable-shared --enable-languages=ada,c,c++,fortran,java,objc --enable-threads=posix --enable-__cxa_atexit --disable-checking --with-gnu-ld --verbose --with-arch=i486 --target=i486-slackware-linux --host=i486-slackware-linux
> Thread model: posix
> gcc version 4.1.
> ---
>
> All traffic went over an USB NIC (D-Link DUB-E100) using the asix driver.
> I have no idea what further information could be useful, so shout =)
>
> ---
> If you only have a hammer, you tend to see every problem as a nail.
>                 -- Maslow
>
>

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
