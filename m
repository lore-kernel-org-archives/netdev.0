From: "Sebastian Piecha" <spi@gmxpro.de>
Subject: Re: oops in skbuff.c
Date: Sun, 26 Oct 2003 23:08:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F9C5402.9225.291F78E8@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>, LK-net <linux-net@vger.kernel.org>,
        <netdev@oss.sgi.com>
Content-description: Mail message body
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > On Thu, 16 Oct 2003, Sebastian Piecha wrote:
> > > 
> > > >  panics. Copying more than 4 GB to the samba share also lets the 
> > > > kernel panic with an OOPS.
> > > 
> > > Does the above cause a panic for the 2.6-test kernels?
> > > Do you have netfilter enabled, and if so, any iptables modules loaded?
> > > 
> > > 
> > I did a mistake. iptables is installed but no rules added. I'll 
> > remove iptables and rerun the check.
> 
> For being sure I removed iptables but again the oops happened. I also 
> tried kernel 2.4.18 without success.
> 
> Does anybody have a clue how to go on?

I reinstalled my system from scratch. Debian testing, kernel 2.4.22, 
samba 2.2.8a. Again the oops is occuring in skbuff.

With kernel 2.6.0-test7 I didn't get any oops. But I'd prefer using a 
stable 2.4.x kernel. There are modifications in skbuff.c in kernel 
2.6.0-test7.
For what reason skbuff.c has changed?
Due to bug fixes or general changes in the kernel?
Could skbuff.c easily be backported to 2.4.20 or 2.4.22?

And here's a copy of the last oops:

Oops: 0000
CPU:    0
EIP:    0010:[<c01c1402>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: c44ca6e0   ebx: 00200000   ecx: c44ca6e0   edx: 00200000
esi: cf80ae20   edi: fffffffd   ebp: 00000046   esp: c029bf10
ds: 0018   es: 0018   ss: 0018
Process swapper (pid: 0, stackpage=c029b000)
Stack: 00000030 cf80ae20 c01c14c9 cf80ae20 cf80ae20 00000030 c01c1513 
cf80ae20
       cf80ae20 cf80ae20 c01c1697 cf80ae20 00000000 00000030 cf8105c0 
cf80ae20
       c01c65e3 cf80ae20 0000000e 00000001 c02ba568 c0121b95 c02ba568 
00000002
Call Trace:    [<c01c14c9>] [<c01c1513>] [<c01c1697>] [<c01c65e3>] 
[<c0121b95>]
  [<c010a88b>] [<c0107080>] [<c010cde8>] [<c0107080>] [<c01070a3>] 
[<c0107132>]
  [<c0105000>]
Code: 8b 42 78 8b 1b 48 74 0a ff 4a 78 0f 94 c0 84 c0 74 08 89 14


>>EIP; c01c1402 <skb_drop_fraglist+22/50>   <=====

>>eax; c44ca6e0 <_end+41d3b18/14516498>
>>ecx; c44ca6e0 <_end+41d3b18/14516498>
>>esi; cf80ae20 <_end+f514258/14516498>
>>esp; c029bf10 <init_task_union+1f10/2000>

Trace; c01c14c9 <skb_release_data+69/a0>
Trace; c01c1513 <kfree_skbmem+13/70>
Trace; c01c1697 <__kfree_skb+127/1c0>
Trace; c01c65e3 <net_tx_action+43/c0>
Trace; c0121b95 <do_softirq+95/a0>
Trace; c010a88b <do_IRQ+9b/a0>
Trace; c0107080 <default_idle+0/40>
Trace; c010cde8 <call_do_IRQ+5/d>
Trace; c0107080 <default_idle+0/40>
Trace; c01070a3 <default_idle+23/40>
Trace; c0107132 <cpu_idle+52/70>
Trace; c0105000 <_stext+0/0>

Code;  c01c1402 <skb_drop_fraglist+22/50>
00000000 <_EIP>:
Code;  c01c1402 <skb_drop_fraglist+22/50>   <=====
   0:   8b 42 78                  mov    0x78(%edx),%eax   <=====
Code;  c01c1405 <skb_drop_fraglist+25/50>
   3:   8b 1b                     mov    (%ebx),%ebx
Code;  c01c1407 <skb_drop_fraglist+27/50>
   5:   48                        dec    %eax
Code;  c01c1408 <skb_drop_fraglist+28/50>
   6:   74 0a                     je     12 <_EIP+0x12>
Code;  c01c140a <skb_drop_fraglist+2a/50>
   8:   ff 4a 78                  decl   0x78(%edx)
Code;  c01c140d <skb_drop_fraglist+2d/50>
   b:   0f 94 c0                  sete   %al
Code;  c01c1410 <skb_drop_fraglist+30/50>
   e:   84 c0                     test   %al,%al
Code;  c01c1412 <skb_drop_fraglist+32/50>
  10:   74 08                     je     1a <_EIP+0x1a>
Code;  c01c1414 <skb_drop_fraglist+34/50>
  12:   89 14 00                  mov    %edx,(%eax,%eax,1)

 <0>Kernel panic: Aiee, killing interrupt handler!



--
Mit freundlichen Gruessen/Best regards,
Sebastian Piecha

EMail: spi@gmxpro.de
