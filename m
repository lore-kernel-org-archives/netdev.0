From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: OOPS when enslaving atmel card to bonded interface (2.6.9-rc2-bk-pull)
Date: Wed, 22 Sep 2004 01:27:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409220127.19174.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Getting the following OOPs at startup when PCMCIA discovers an SMC wireless
card (atmel_cs) and tries to enslave it to bond0. The kernel is last night
pull form Linus.

-- 
Dmitry

ep 22 01:12:51 core kernel: eth1: SMC 2632W-V2 index 0x01: Vcc 3.3, irq 3, io 0x0100-0x011f
Sep 22 01:12:51 core kernel: Unable to handle kernel paging request at virtual address 962da8e8
Sep 22 01:12:51 core kernel:  printing eip:
Sep 22 01:12:51 core kernel: c02c5c99
Sep 22 01:12:51 core kernel: *pde = 00000000
Sep 22 01:12:51 core kernel: Oops: 0000 [#1]
Sep 22 01:12:51 core kernel: PREEMPT
Sep 22 01:12:51 core kernel: Modules linked in: atmel_cs atmel firmware_class crc32 3c59x bonding iptable_filter snd_maestro3 sn
d_ac97_codec snd_pcm snd_timer snd_page_alloc snd soundcore uhci_hcd usbcore mousedev psmouse
Sep 22 01:12:51 core kernel: CPU:    0
Sep 22 01:12:51 core kernel: EIP:    0060:[<c02c5c99>]    Not tainted VLI
Sep 22 01:12:51 core kernel: EFLAGS: 00010287   (2.6.9-rc2)
Sep 22 01:12:51 core kernel: EIP is at fn_hash_insert+0x3a9/0x420
Sep 22 01:12:51 core kernel: eax: 00000000   ebx: de985e68   ecx: 962da8c0   edx: 00000c01
Sep 22 01:12:51 core kernel: esi: deed7268   edi: dfbad2c0   ebp: de985e00   esp: de985d94
Sep 22 01:12:51 core kernel: ds: 007b   es: 007b   ss: 0068
Sep 22 01:12:51 core kernel: Process ifenslave (pid: 2388, threadinfo=de985000 task=df8c6aa0)
Sep 22 01:12:51 core kernel: Stack: de985dec de9c3440 de985db4 c017eb96 def2b280 00000000 962da8c0 de9e731c
Sep 22 01:12:51 core kernel:        de980c01 c011e831 00004000 de9c3b60 def2b280 962da8c0 009c3b60 00000002
Sep 22 01:12:51 core kernel:        00000020 df1e3860 de985e04 deed7260 00000004 dfc9ade0 ffffffef 962da8c0
Sep 22 01:12:51 core kernel: Call Trace:
Sep 22 01:12:51 core kernel:  [<c01056aa>] show_stack+0x7a/0x90
Sep 22 01:12:51 core kernel:  [<c010582a>] show_registers+0x14a/0x1c0
Sep 22 01:12:51 core kernel:  [<c0105a1b>] die+0xdb/0x170
Sep 22 01:12:51 core kernel:  [<c01140da>] do_page_fault+0x23a/0x590
Sep 22 01:12:51 core kernel:  [<c0105295>] error_code+0x2d/0x38
Sep 22 01:12:51 core kernel:  [<c02c3617>] fib_magic+0xd7/0xf0
Sep 22 01:12:51 core kernel:  [<c02c3694>] fib_add_ifaddr+0x64/0x160
Sep 22 01:12:51 core kernel:  [<c02c39db>] fib_inetaddr_event+0x4b/0x50
Sep 22 01:12:51 core kernel:  [<c0125028>] notifier_call_chain+0x28/0x50
Sep 22 01:12:51 core kernel:  [<c02bb630>] inet_insert_ifa+0xa0/0x150
Sep 22 01:12:51 core kernel:  [<c02bbf99>] devinet_ioctl+0x349/0x6f0
Sep 22 01:12:51 core kernel:  [<c02be193>] inet_ioctl+0x63/0xa0
Sep 22 01:12:51 core kernel:  [<c0275c02>] sock_ioctl+0x102/0x2a0
Sep 22 01:12:51 core kernel:  [<c0162206>] sys_ioctl+0xf6/0x240
Sep 22 01:12:51 core kernel:  [<c01050eb>] syscall_call+0x7/0xb
Sep 22 01:12:51 core kernel: Code: 8b 46 04 8b 30 8b 0e 89 4d a4 0f 18 01 90 3b 76 04 74 37 8b 47 28 89 45 a8 89 f6 8d bc 27 00
00 00 00 8b 4e 08 8b 45 a8 89 4d ac <39> 41 28 75 1a 0f b6 46 0d 3b 45 d0 74 25 8b 75 a4 8b 06 89 45
