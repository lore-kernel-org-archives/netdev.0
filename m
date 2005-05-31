From: Phil Oester <kernel@linuxace.com>
Subject: 2.6.12-rcx networking oops
Date: Tue, 31 May 2005 15:40:12 -0700
Message-ID: <20050531224012.GA16789@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At Andrew's suggestion, I tested the latest 2.6.12-rc5-gitx, and am still
hitting an oops on a gateway box under load.  From comparing the various
oops, it seems like a dev is disappearing while one CPU is in the middle
of processing traffic.  At least that's what my naive analysis leads
me to believe.

The latest oops is the first shown below (2.6.12-rc5-git5), and seems to be
here:

0xc0270d3f is in fib_validate_source (net/ipv4/fib_frontend.c:195).
195             if (FIB_RES_DEV(res) == dev)

The second oops below was against 2.6.12-rc4, hitting here:

0xc026a59a is in inet_select_addr (inetdevice.h:159).
159             return (struct in_device*)dev->ip_ptr;

The third oops below is also against 2.6.12-rc4, hitting here:
0xc026dbba is in ip_check_mc (net/ipv4/igmp.c:2101).
2101            for (im=in_dev->mc_list; im; im=im->next) {

Since I'm trying to update a 2.6.10 box, Herbert Xu asked me to test each
2.6.11-rc to see where the problem begins, but it appears around 2.6.11-rc2
some LLTX changes were made which caused lockups (they were later
reverted before 2.6.11-final).  So, I can't really tell when this started.

Any further suggestions?

Phil


Unable to handle kernel NULL pointer dereference at virtual address 00000060
 printing eip:
c0270d3f
*pde = 00000000
Oops: 0000 [#1]
SMP 
CPU:    0
EIP:    0060:[<c0270d3f>]    Not tainted VLI
EFLAGS: 00010206   (2.6.12-rc5-git5) 
EIP is at fib_validate_source+0xcf/0x1f0
eax: f7c2c000   ebx: c0337dec   ecx: f7c258a0   edx: 00000000
esi: c0335c2c   edi: 00000000   ebp: c0337db0   esp: c0337d40
ds: 3f1f   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0337000 task=c02b9bc0)
Stack: 00000000 3b6014aa 00000000 00010000 f7b7a460 00000000 00000002 3b6014aa 
       4f7514aa 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
       00000000 00000000 00000000 00000000 00000000 00000000 00000000 c0337e00 
Call Trace:
 [<c010389a>] show_stack+0x7a/0x90
 [<c0103a1d>] show_registers+0x14d/0x1b0
 [<c0103c1d>] die+0xed/0x170
 [<c010f05a>] do_page_fault+0x30a/0x65a
 [<c01034e3>] error_code+0x4f/0x54
 [<c0244795>] ip_route_input_slow+0x445/0x840
 [<c0244c2a>] ip_route_input+0x9a/0x160
 [<c0246d00>] ip_rcv+0x3b0/0x4d0
 [<c02342ea>] netif_receive_skb+0x13a/0x1a0
 [<c01f8d10>] e1000_clean_rx_irq+0x180/0x4d0
 [<c01f8550>] e1000_clean+0x40/0xe0
 [<c0234500>] net_rx_action+0x90/0x130
 [<c011a804>] __do_softirq+0xd4/0xf0
 [<c0104f82>] do_softirq+0x52/0x70
 =======================
 [<c011a8ea>] irq_exit+0x3a/0x40
 [<c0104e70>] do_IRQ+0x50/0x70
 [<c010338a>] common_interrupt+0x1a/0x20
 [<c0100a8b>] cpu_idle+0x7b/0x80
 [<c01002be>] rest_init+0x1e/0x20
 [<c02fc96c>] start_kernel+0x14c/0x170
 [<c010020e>] 0xc010020e
Code: ff 83 c4 64 5b 5e 5f 5d c3 89 d0 e8 4c 09 00 00 eb ea 8b 46 04 8b 40 24 85 c0 0f 84 00 01 00 
00 8b 5d 10 89 03 8b 56 04 8b 45 0c <39> 42 60 0f 84 dd 00 00 00 85 d2 74 0f f0 ff 4a 14 0f 94 c0 84 

Unable to handle kernel NULL pointer dereference at virtual address 000000ec
 printing eip:
c026a59a
*pde = 00000000
Oops: 0000 [#1]
SMP 
CPU:    1
EIP:    0060:[<c026a59a>]    Not tainted VLI
EFLAGS: 00010246   (2.6.12-rc4) 
EIP is at inet_select_addr+0xa/0xf0
eax: 00000000   ebx: c1bb4720   ecx: 00000000   edx: 00000000
esi: 00000000   edi: 00000000   ebp: c0333d60   esp: c0333d54
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0333000 task=c191b520)
Stack: c1bb4720 c0333d74 00000000 c0333dd8 c026eb0b 00000000 3e6014aa 00000000 
       0001001d f78d169f 00000000 00000001 3e6014aa 25e65e42 00000000 00000000 
       00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
Call Trace:
 [<c01038ba>] show_stack+0x7a/0x90
 [<c0103a3d>] show_registers+0x14d/0x1b0
 [<c0103c3d>] die+0xed/0x170
 [<c010f05a>] do_page_fault+0x30a/0x65a
 [<c0103503>] error_code+0x4f/0x54
 [<c026eb0b>] fib_validate_source+0x1cb/0x1f0
 [<c0242305>] ip_route_input_slow+0x445/0x840
 [<c0244890>] ip_rcv+0x3b0/0x4d0
 [<c0231e3a>] netif_receive_skb+0x13a/0x1a0
 [<c01f87e6>] e1000_clean_rx_irq+0x156/0x480
 [<c01f822f>] e1000_clean+0x3f/0xe0
 [<c0232050>] net_rx_action+0x90/0x130
 [<c011a884>] __do_softirq+0xd4/0xf0
 [<c0104fc2>] do_softirq+0x52/0x70
 =======================
 [<c0104eb0>] do_IRQ+0x50/0x70
 [<c01033aa>] common_interrupt+0x1a/0x20
 [<c0100a82>] cpu_idle+0x72/0x80
 [<00000000>] stext+0x3feffd6c/0xc
 [<c191ffb4>] 0xc191ffb4
Code: 30 5b 5e 5f 5d c3 c7 45 c4 f2 <7> ff ff ff eb ec 89 f6 8b 75 d0 eb ae 8d 74 26 00 8d bc 27 00 00 00 00 55 89 e5 57 31 ff 56 89 ce 53 <8b> 80 ec 00 00 00 85 c0 74 38 8b 48 0c 85 c9 74 2d f6 41 25 01 

Unable to handle kernel NULL pointer dereference at virtual address 00000060
 printing eip: c026b44a
*pde = 00000000
Oops: 0000 [#1]
SMP 
CPU:    1
EIP:    0060:[<c026b44a>]    Not tainted VLI
EFLAGS: 00010206   (2.6.12-rc4) 
EIP is at ip_check_mc+0x2a/0xb0
eax: 026014aa   ebx: c1bb4720   ecx: f7a51e60   edx: 00000000
esi: c033bbe6   edi: 0000b9e6   ebp: f7c29000   esp: c0331d88
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0331000 task=c191b520)
Stack: 00000000 3e6014aa 00000000 0001001d f7044f60 00000000 00000001 3e6014aa 
       7525bece 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
       00000000 00000000 00000000 00000000 00000000 00000000 00000000 c0331e44 
Call Trace:
 [<c024051a>] ip_route_input_slow+0x3da/0x760
 [<c0242939>] ip_rcv+0x3b9/0x4d0
 [<c0242bb0>] ip_rcv_finish+0x0/0x240
 [<c0111f48>] __wake_up+0x38/0x50
 [<c02304ea>] netif_receive_skb+0x13a/0x1a0
 [<c01f748e>] e1000_clean_rx_irq+0x16e/0x4c0
 [<c01f711f>] e1000_clean_tx_irq+0x1af/0x3b0
 [<c01f6ecc>] e1000_clean+0x3c/0xe0
 [<c02306ef>] net_rx_action+0x7f/0x110
 [<c011a414>] __do_softirq+0xd4/0xf0
 [<c010507f>] do_softirq+0x4f/0x60
 =======================
 [<c0104f6d>] do_IRQ+0x4d/0x70
 [<c0103406>] common_interrupt+0x1a/0x20
 [<c0100990>] default_idle+0x0/0x30
 [<c01009b3>] default_idle+0x23/0x30
 [<c0100a70>] cpu_idle+0x70/0x80
Code: 90 55 31 ed 57 56 89 d6 53 83 ec 08 89 c3 89 4c 24 04 8d 40 10 89 04 24 0f b7 7c 24 1c e8 3f be 01 00 8b 43 14 85 c0 74 14 90 8d <b4> 26 00 00 00 00 39 70 04 74 19 8b 40 1c 85 c0 75 f4 8b 04 24 
