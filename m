From: Ben Greear <greearb@candelatech.com>
Subject: Re: Problems with e1000 in 2.4.23
Date: Sun, 30 Nov 2003 00:35:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC9ABCC.2050006@candelatech.com>
References: <3FC99775.5020300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <3FC99775.5020300@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


3 more data points:

I copied the e1000 from 2.4.23-pre9 to 2.4.23, tx-watchdog problem still happened.

I tried vanilla 2.4.23 (ie, none of my hacks), tx-watchdog problem still happened,
   but took slightly longer (around 2 minutes instead of 30 seconds).

Booted 2.4.23-pre9 again just to make sure, ran for quite a while w/out a problem,
then crashed hard (hand-copied from console and ran through ksymoops, its possible
I typo'd something).

So, not sure what to blame, but if anyone wants a used Dual-AMD box, I now have
one for sale!

Ben


ksymoops 2.4.5 on i686 2.4.23-pre9.  Options used
      -V (default)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.23-pre9/ (default)
      -m /boot/System.map-2.4.23-pre9 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Error (expand_objects): cannot stat(/lib/ext3.o) for ext3
Error (expand_objects): cannot stat(/lib/jbd.o) for jbd
Warning (map_ksym_to_module): cannot match loaded module ext3 to a unique module object.  Trace may not be reliable.
invalid operand: 0000
CPU:    1
EFLAGS: 00010286
eax: 00000026   ebx: b1b0afae     ecx: 00000092       edx: ded2df7c
esi: dd35f080   edi: dae28890     ebp: 00000889       esp: c158fea0
ds: 0018        es: 0018       ss:0018
Process swapper (pid: 0, stackpage=c158f000)
Stack: c026f5e0 00000320 e0903f3e 00000320 c01f0bd7 dc84b380 00000000 00000030
        dcf80000 e090ebbe 00000001 00000049 dd6accd8 dd614800 dd614a50 c158ff24
        00000040 dd614800 dd614980 e090e963 dd614980 c158fefc 00000040 00000001
Call Trace:    [<e090ef3e>] [<c01f0bd7>] [<e090ebbe>] [<e090e963>] [<c01f584e>]
   [<c012538e>] [<c010adec>] [<c0106f20>] [<c010d818>] [<c0106f20>] [<c0106f4c>]
   [<c0106fc2>] [<c01200db>] [<c0120347>]
Code: 0f 0b 95 00 1a 03 27 c0 90 eb fe 90 90 90 90 90 90 90 90 90
Using defaults from ksymoops -t elf32-i386 -a i386


 >>ebx; b1b0afae Before first symbol
 >>edx; ded2df7c <_end+1e9db344/204ba448>
 >>esi; dd35f080 <_end+1d00c448/204ba448>
 >>edi; dae28890 <_end+1aad5c58/204ba448>
 >>ebp; 00000889 Before first symbol
 >>esp; c158fea0 <_end+123d268/204ba448>

Trace; e090ef3e <[e1000]e1000_clean_rx_irq+36e/370>
Trace; c01f0bd7 <__kfree_skb+117/170>
Trace; e090ebbe <[e1000]e1000_clean_tx_irq+1ee/200>
Trace; e090e963 <[e1000]e1000_clean+43/b0>
Trace; c01f584e <net_rx_action+9e/140>
Trace; c012538e <do_softirq+ce/d0>
Trace; c010adec <do_IRQ+dc/e0>
Trace; c0106f20 <default_idle+0/40>
Trace; c010d818 <call_do_IRQ+5/d>
Trace; c0106f20 <default_idle+0/40>
Trace; c0106f4c <default_idle+2c/40>
Trace; c0106fc2 <cpu_idle+42/60>
Trace; c01200db <call_console_drivers+5b/120>
Trace; c0120347 <printk+137/170>

Code;  00000000 Before first symbol
00000000 <_EIP>:
Code;  00000000 Before first symbol
    0:   0f 0b                     ud2a
Code;  00000002 Before first symbol
    2:   95                        xchg   %eax,%ebp
Code;  00000003 Before first symbol
    3:   00 1a                     add    %bl,(%edx)
Code;  00000005 Before first symbol
    5:   03 27                     add    (%edi),%esp
Code;  00000007 Before first symbol
    7:   c0 90 eb fe 90 90 90      rclb   $0x90,0x9090feeb(%eax)
Code;  0000000e Before first symbol
    e:   90                        nop
Code;  0000000f Before first symbol
    f:   90                        nop
Code;  00000010 Before first symbol
   10:   90                        nop
Code;  00000011 Before first symbol
   11:   90                        nop
Code;  00000012 Before first symbol
   12:   90                        nop
Code;  00000013 Before first symbol
   13:   90                        nop

  <0>Kernel panic: Aiee, killing interrupt handler!

2 warnings and 2 errors issued.  Results may not be reliable.



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
