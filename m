From: Jamie Lenehan <lenehan@twibble.org>
Subject: 2.5.69 IPv6 (modular) crash on boot
Date: Wed, 7 May 2003 09:20:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506232037.GA5576@twibble.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IPv6 worked fine in 2.5.68, but I get a crash in 2.5.69 on boot. I
haven't seen anyone else mention this though. This is a RedHat 8
systems with the new modutils added and pretty much everything built
modular:

May  5 18:46:50 nynaeve kernel: IPv6 v0.8 for NET4.0
May  5 18:46:50 nynaeve kernel: ------------[ cut here ]------------
May  5 18:46:50 nynaeve kernel: kernel BUG at include/linux/module.h:284!
May  5 18:46:50 nynaeve kernel: invalid operand: 0000 [#1]
May  5 18:46:50 nynaeve kernel: CPU:    0
May  5 18:46:50 nynaeve kernel: EIP:    0060:[<f09753eb>]    Not tainted
May  5 18:46:50 nynaeve kernel: EFLAGS: 00010246
May  5 18:46:50 nynaeve kernel: EIP is at inet6_create+0x38b/0x430 [ipv6]
May  5 18:46:50 nynaeve kernel: eax: 00000000   ebx: ee6e4000   ecx: 00000001   edx: f09a7100
May  5 18:46:50 nynaeve kernel: esi: 0000003a   edi: f09a53c0   ebp: ee585c00   esp: ee6e5f08
May  5 18:46:50 nynaeve kernel: ds: 007b   es: 007b   ss: 0068
May  5 18:46:50 nynaeve kernel: Process modprobe (pid: 602, threadinfo=ee6e4000 task=ef336780)
May  5 18:46:50 nynaeve kernel: Stack: f09a7080 ee585c00 0000039c efd354f0 00000001 0000000a ffffff9f eff9c800 
May  5 18:46:50 nynaeve kernel:        c0218b50 eff9c800 0000003a effa2400 00000003 c01202a5 f09a6820 effa2400 
May  5 18:46:50 nynaeve kernel:        effa2400 0000416d ef2ca720 f09a6880 00000000 c02b72b8 f09a7080 c02b72b8 
May  5 18:46:50 nynaeve kernel: Call Trace:
May  5 18:46:50 nynaeve kernel:  [<f09a7080>] +0x0/0x200 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<c0218b50>] sock_create+0xf0/0x280
May  5 18:46:50 nynaeve kernel:  [<c01202a5>] register_proc_table+0x95/0x130
May  5 18:46:50 nynaeve kernel:  [<f09a6820>] ipv6_net_table+0x0/0x60 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f09a6880>] ipv6_root_table+0x0/0x60 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f09a7080>] +0x0/0x200 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f08097cb>] icmpv6_init+0x2b/0xc0 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f09a7cc8>] __icmpv6_socket+0x0/0x4 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f08091ca>] inet6_init+0x14a/0x320 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<f09a53a8>] inet6_family_ops+0x0/0x18 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<c013082f>] sys_init_module+0x12f/0x1e0
May  5 18:46:50 nynaeve kernel:  [<f09a7080>] +0x0/0x200 [ipv6]
May  5 18:46:50 nynaeve kernel:  [<c010930b>] syscall_call+0x7/0xb
May  5 18:46:50 nynaeve kernel: 
May  5 18:46:50 nynaeve kernel: Code: 0f 0b 1c 01 b8 ae 99 f0 e9 d4 fd ff ff 0f 0b 1e 01 cf ae 99 

Full boot messages at: http://twibble.org/dist/2.5.69-ipv6/log.txt
And .config at: http://twibble.org/dist/2.5.69-ipv6/config.txt

-- 
 Jamie Lenehan              Work Phone: +61 3 9843 8817
 lenehan@twibble.org        Work Email: jamie.lenehan@activcard.com.au
