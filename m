From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2979] New: kernel BUG at net/appletalk/ddp.c
Date: Tue, 29 Jun 2004 13:37:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629133730.4595189b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 29 Jun 2004 03:43:31 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2979] New: kernel BUG at net/appletalk/ddp.c


http://bugme.osdl.org/show_bug.cgi?id=2979

           Summary: kernel BUG at net/appletalk/ddp.c
    Kernel Version: 2.6.7
            Status: NEW
          Severity: high
             Owner: acme@conectiva.com.br
         Submitter: philipp@linbit.com


Distribution: Debian 3.0 (Woody) 
Hardware Environment: Dell PowerEdge 2650 Dual CPU  
Software Environment: Netatalk 1.63 
Steps to reproduce: Random Crashes in ~ 1 Week Intervals 
Problem Description: We have random crashes at a school with a mixed PC/Mac 
Network. We have about 300 Mac PC's and 200 PC's. The crashes happen in 
Intervals of about 1 Weeks. We are not able to reproduce the crashes. We are 
now using vanilla kernel 2.6.7 (SMP, Highmem). We had these crashes with 
kernel 2.4.25 (SMP, Highmem; UP, Highmem)also. See attached Oopses. I don't 
know if the Oopses are directly related but the frequency of their occurence 
suggests so. It seems to that something on the network generates bad appletalk 
traffic  
 
2.6.7 SMP, Highmem: 
------------------< cut <------------------ 
kernel BUG at net/appletalk/ddp.c:1018! 
invalid operand: 0000 [#1] 
SMP 
Modules linked in: snd_pcm_oss snd_pcm snd_page_alloc snd_timer snd_mixer_oss 
snd soundcore appletalk psnap llc parport_pc lp parport ipv6 tg3 psmouse 
CPU:    2 
EIP:    0060:[<f8c0d5bb>]    Not tainted 
EFLAGS: 00010206   (2.6.7sv-p3-smp-highmem) 
EIP is at atalk_sum_skb+0x1eb/0x200 [appletalk] 
eax: 00000000   ebx: 00000011   ecx: 00000000   edx: cf804680 
esi: cf804680   edi: 00000006   ebp: f770e000   esp: f7f87e18 
ds: 007b   es: 007b   ss: 0068 
Process swapper (pid: 0, threadinfo=f7f86000 task=f7f9eb50) 
Stack: c1bde760 cf804680 00000015 f770e000 cf804680 00000000 00000015 f8c0d5e6 
       cf804680 00000015 00000017 000065ef f8c0de9f cf804680 0000001b cf804680 
       cf804680 f7bce8a8 c0636e00 cf804680 e41b4680 0000003a dcb9d500 cf804680 
Call Trace: 
 [<f8c0d5e6>] atalk_checksum+0x16/0x2c [appletalk] 
 [<f8c0de9f>] atalk_rcv+0xf3/0x27c [appletalk] 
 [<f8ba2097>] snap_rcv+0x53/0x8c [psnap] 
 [<f8bfd387>] llc_rcv+0x14b/0x214 [llc] 
 [<c0354c71>] netif_receive_skb+0x191/0x1c8 
 [<f8bc4d36>] tg3_rx+0x29a/0x3b8 [tg3] 
 [<f8bc4eee>] tg3_poll+0x9a/0x12c [tg3] 
 [<c0354e3e>] net_rx_action+0x82/0x11c 
 [<c011d35e>] __do_softirq+0x4e/0xa4 
 [<c011d3dc>] do_softirq+0x28/0x30 
 [<c0107833>] do_IRQ+0x113/0x124 
 [<c0106010>] common_interrupt+0x18/0x20 
 [<c0103afc>] default_idle+0x2c/0x34 
 [<c0103b7c>] cpu_idle+0x30/0x40 
 [<c05ccfea>] start_secondary+0x72/0x74 
 [<c011a421>] printk+0x11d/0x134 
 [<c05c9ab3>] print_cpu_info+0xa3/0xbc 
 [<c05cd31e>] do_boot_cpu+0x112/0x178 
 
Code: 0f 0b fa 03 9f fa c0 f8 8b 44 24 2c 5b 5e 5f 5d 83 c4 0c c3 
 <0>Kernel panic: Fatal exception in interrupt 
In interrupt handler - not syncing 
------------------< cut <------------------ 
 
2.4.25 SMP, Highmem 
------------------< cut <------------------ 
CPU:    0 
EIP:    0010:[<c0118665>]    Not tainted 
Using defaults from ksymoops -t elf32-i386 -a i386 
EFLAGS: 00000086 
eax: f3722710   ebx: f3722710   ecx: 00000001   edx: 00000001 
esi: f499aa00   edi: f3722710   ebp: c0457ea0   esp: c0457e84 
ds: 0018   es: 0018   ss: 0018 
Process swapper (pid: 0, stackpage=c0457000) 
Stack: f3722710 f499aa00 f8bfda20 f7536b40 c03137d7 00000282 00000001 f8bfdaa0 
       c03051a3 f499aa00 c3b9df20 c030474d f499aa00 c3b9df24 c030581f e45ea3a0 
       c3b9df24 f8bfda20 f8bf80c8 e45ea3a0 f8bfda60 0000000f f8bf84eb c3b9df20 
Call Trace:    [<f8bfda20>] [<c03137d7>] [<f8bfdaa0>] [<c03051a3>] 
[<c030474d>] 
  [<c030581f>] [<f8bfda20>] [<f8bf80c8>] [<f8bfda60>] [<f8bf84eb>] 
[<f8bfda60>] 
  [<f8bf857c>] [<f8bfda60>] [<f8bfda20>] [<f8bf8538>] [<c01225ef>] 
[<c011f130>] 
  [<c011f013>] [<c011ed9d>] [<c010a37b>] [<c0106d60>] [<c0106d60>] 
[<c0106d60>] 
  [<c0106d60>] [<c0106d8c>] [<c0106df2>] [<c0105000>] [<c010504f>] 
Code: 7e f9 e9 77 ef ff ff 80 3d 80 ec 48 c0 00 f3 90 7e f5 e9 94 
 
 
>>EIP; c0118665 <.text.lock.sched+8f/1da>   <===== 
 
>>eax; f3722710 <_end+332177b4/386960a4> 
>>ebx; f3722710 <_end+332177b4/386960a4> 
>>esi; f499aa00 <_end+3448faa4/386960a4> 
>>edi; f3722710 <_end+332177b4/386960a4> 
>>ebp; c0457ea0 <init_task_union+1ea0/2000> 
>>esp; c0457e84 <init_task_union+1e84/2000> 
 
Trace; f8bfda20 <[appletalk]resolved+0/0> 
Trace; c03137d7 <p8022_rcv+57/88> 
Trace; f8bfdaa0 <[appletalk]proxies+0/40> 
Trace; c03051a3 <sock_def_write_space+43/88> 
Trace; c030474d <sock_wfree+21/3c> 
Trace; c030581f <__kfree_skb+77/140> 
Trace; f8bfda20 <[appletalk]resolved+0/0> 
Trace; f8bf80c8 <[appletalk]__aarp_expire+68/7c> 
Trace; f8bfda60 <[appletalk]unresolved+0/40> 
Trace; f8bf84eb <[appletalk]__aarp_kick+23/40> 
Trace; f8bfda60 <[appletalk]unresolved+0/40> 
Trace; f8bf857c <[appletalk]aarp_expire_timeout+44/c8> 
Trace; f8bfda60 <[appletalk]unresolved+0/40> 
Trace; f8bfda20 <[appletalk]resolved+0/0> 
Trace; f8bf8538 <[appletalk]aarp_expire_timeout+0/c8> 
Trace; c01225ef <timer_bh+293/3d0> 
Trace; c011f130 <bh_action+4c/88> 
Trace; c011f013 <tasklet_hi_action+67/a0> 
Trace; c011ed9d <do_softirq+7d/dc> 
Trace; c010a37b <do_IRQ+db/ec> 
Trace; c0106d60 <default_idle+0/34> 
Trace; c0106d60 <default_idle+0/34> 
Trace; c0106d60 <default_idle+0/34> 
Trace; c0106d60 <default_idle+0/34> 
Trace; c0106d8c <default_idle+2c/34> 
Trace; c0106df2 <cpu_idle+3e/54> 
Trace; c0105000 <_stext+0/0> 
Trace; c010504f <rest_init+4f/50> 
 
Code;  c0118665 <.text.lock.sched+8f/1da> 
00000000 <_EIP>: 
Code;  c0118665 <.text.lock.sched+8f/1da>   <===== 
   0:   7e f9                     jle    fffffffb <_EIP+0xfffffffb> c0118660 
<.text.lock.sched+8a/1da>   <===== 
Code;  c0118667 <.text.lock.sched+91/1da> 
   2:   e9 77 ef ff ff            jmp    ffffef7e <_EIP+0xffffef7e> c01175e3 
<__wake_up+1b/c4> 
Code;  c011866c <.text.lock.sched+96/1da> 
   7:   80 3d 80 ec 48 c0 00      cmpb   $0x0,0xc048ec80 
Code;  c0118673 <.text.lock.sched+9d/1da> 
   e:   f3 90                     repz nop 
Code;  c0118675 <.text.lock.sched+9f/1da> 
  10:   7e f5                     jle    7 <_EIP+0x7> c011866c 
<.text.lock.sched+96/1da> 
Code;  c0118677 <.text.lock.sched+a1/1da> 
  12:   e9 94 00 00 00            jmp    ab <_EIP+0xab> c0118710 
<.text.lock.sched+13a/1da> 
------------------< cut <------------------ 
 
2.4.25 UP, Highmem: 
------------------< cut <------------------ 
Unable to handle kernel NULL pointer dereference at virtual address 00000000 
c0113e94 
*pde = 00000000 
Oops: 0000 
CPU:    0 
EIP:    0010:[<c0113e94>]    Not tainted 
Using defaults from ksymoops -t elf32-i386 -a i386 
EFLAGS: 00010086 
eax: d38a4530   ebx: 00000000   ecx: 00000001   edx: 00000001 
esi: d38a4530   edi: 00000001   ebp: c04a9ec4   esp: c04a9eac 
ds: 0018   es: 0018   ss: 0018 
Process swapper (pid: 0, stackpage=c04a9000) 
Stack: d38a4530 d3542440 f8bfba8c f7d13600 00000286 00000001 f8bfbb0c c035d89b 
       d3542440 c2c4c920 c035cf8c d3542440 c2c4c924 c035ddfd f67f86a0 c2c4c924 
       f8bfba8c f8bf70be f67f86a0 f8bfbacc 0000000c f8bf74db c2c4c920 f8bfbacc 
Call Trace:    [<f8bfba8c>] [<f8bfbb0c>] [<c035d89b>] [<c035cf8c>] 
[<c035ddfd>] 
  [<f8bfba8c>] [<f8bf70be>] [<f8bfbacc>] [<f8bf74db>] [<f8bfbacc>] 
[<f8bf7552>] 
  [<f8bfbacc>] [<f8bfba8c>] [<f8bf7528>] [<c011d5ec>] [<c011a612>] 
[<c011a556>] 
  [<c011a37a>] [<c0109a32>] [<c0106ce0>] [<c0106ce0>] [<c0106ce0>] 
[<c0106ce0>] 
  [<c0106d03>] [<c0106d69>] [<c0105000>] [<c0105027>] 
Code: 8b 03 0f 18 00 83 c6 04 89 75 f4 39 f3 74 69 8b 4b fc 8b 01 
 
 
>>EIP; c0113e94 <__wake_up+20/a4>   <===== 
 
>>eax; d38a4530 <_end+13381d94/3867e864> 
>>esi; d38a4530 <_end+13381d94/3867e864> 
>>ebp; c04a9ec4 <init_task_union+1ec4/2000> 
>>esp; c04a9eac <init_task_union+1eac/2000> 
 
Trace; f8bfba8c <[appletalk].bss.start+c/40> 
Trace; f8bfbb0c <[appletalk]proxies+c/40> 
Trace; c035d89b <sock_def_write_space+33/70> 
Trace; c035cf8c <sock_wfree+20/38> 
Trace; c035ddfd <__kfree_skb+69/130> 
Trace; f8bfba8c <[appletalk].bss.start+c/40> 
Trace; f8bf70be <[appletalk]__aarp_expire+5e/70> 
Trace; f8bfbacc <[appletalk]unresolved+c/40> 
Trace; f8bf74db <[appletalk]__aarp_kick+23/40> 
Trace; f8bfbacc <[appletalk]unresolved+c/40> 
Trace; f8bf7552 <[appletalk]aarp_expire_timeout+2a/94> 
Trace; f8bfbacc <[appletalk]unresolved+c/40> 
Trace; f8bfba8c <[appletalk].bss.start+c/40> 
Trace; f8bf7528 <[appletalk]aarp_expire_timeout+0/94> 
Trace; c011d5ec <timer_bh+24c/368> 
Trace; c011a612 <bh_action+1a/40> 
Trace; c011a556 <tasklet_hi_action+4a/70> 
Trace; c011a37a <do_softirq+5a/a4> 
Trace; c0109a32 <do_IRQ+96/a8> 
Trace; c0106ce0 <default_idle+0/28> 
Trace; c0106ce0 <default_idle+0/28> 
Trace; c0106ce0 <default_idle+0/28> 
Trace; c0106ce0 <default_idle+0/28> 
Trace; c0106d03 <default_idle+23/28> 
Trace; c0106d69 <cpu_idle+41/54> 
Trace; c0105000 <_stext+0/0> 
Trace; c0105027 <rest_init+27/28> 
 
Code;  c0113e94 <__wake_up+20/a4> 
00000000 <_EIP>: 
Code;  c0113e94 <__wake_up+20/a4>   <===== 
   0:   8b 03                     mov    (%ebx),%eax   <===== 
Code;  c0113e96 <__wake_up+22/a4> 
   2:   0f 18 00                  prefetchnta (%eax) 
Code;  c0113e99 <__wake_up+25/a4> 
   5:   83 c6 04                  add    $0x4,%esi 
Code;  c0113e9c <__wake_up+28/a4> 
   8:   89 75 f4                  mov    %esi,0xfffffff4(%ebp) 
Code;  c0113e9f <__wake_up+2b/a4> 
   b:   39 f3                     cmp    %esi,%ebx 
Code;  c0113ea1 <__wake_up+2d/a4> 
   d:   74 69                     je     78 <_EIP+0x78> c0113f0c 
<__wake_up+98/a4> 
Code;  c0113ea3 <__wake_up+2f/a4> 
   f:   8b 4b fc                  mov    0xfffffffc(%ebx),%ecx 
Code;  c0113ea6 <__wake_up+32/a4> 
  12:   8b 01                     mov    (%ecx),%eax 
 
 <0>Kernel panic: Aiee, killing interrupt handler! 
------------------< cut <------------------

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
