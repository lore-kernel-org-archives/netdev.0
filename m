From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: [Bug 2971] New: Oops: tcp_retransmit_skb]
Date: Mon, 28 Jun 2004 12:44:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E07531.7080500@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We've been looking into the ASSERTION failure, but this is
the first I've seen this oops. Anyone run into this before?


thanks,
Nivedita


-------- Original Message --------
Subject: [Bug 2971] New: Oops: tcp_retransmit_skb
Date: Sun, 27 Jun 2004 18:45:55 -0700
From: bugme-daemon@osdl.org
To: niv@us.ibm.com

http://bugme.osdl.org/show_bug.cgi?id=2971

            Summary: Oops: tcp_retransmit_skb
     Kernel Version: 2.6.6
             Status: NEW
           Severity: high
              Owner: niv@us.ibm.com
          Submitter: ranko@spidernet.net


Distribution:
Fedora

Hardware Environment:
Intel SHG2 Xeon Motherboard, 2 x 2.40GHz Xeon CPU, 4GB RAM, 1 x e100, 1 x e1000
(inactive)

lspci output:
00:00.0 Host bridge: ServerWorks CMIC-LE (rev 13)
00:00.1 Host bridge: ServerWorks CMIC-LE
00:00.2 Host bridge: ServerWorks: Unknown device 0000
00:02.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
00:03.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 0d)
00:0f.0 ISA bridge: ServerWorks CSB5 South Bridge (rev 93)
00:0f.1 IDE interface: ServerWorks CSB5 IDE Controller (rev 93)
00:0f.2 USB Controller: ServerWorks OSB4/CSB5 OHCI USB Controller (rev 05)
00:0f.3 Host bridge: ServerWorks GCLE Host Bridge
00:11.0 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
00:11.2 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
01:04.0 Ethernet controller: Intel Corp. 82544GC Gigabit Ethernet Controller
(LOM) (rev 02)
02:09.0 SCSI storage controller: Adaptec AIC-7899P U160/m (rev 01)
02:09.1 SCSI storage controller: Adaptec AIC-7899P U160/m (rev 01)

*Gigabit is not currently active (unplugged)


Software Environment:
Relatively busy caching proxy machine

Problem Description:
Unable to handle kernel paging request at virtual address 22fa7b7d
  printing eip:
c02dab10
*pde = 00000000
Oops: 0000 [#1]
SMP
CPU:    1
EIP:    0060:[<c02dab10>]    Not tainted
EFLAGS: 00010213   (2.6.6)
EIP is at pskb_copy+0xe0/0x180
eax: e478de00   ebx: f54fdc80   ecx: e478de00   edx: 22fa7b7d
esi: 00000000   edi: e478d8ec   ebp: e0f89480   esp: f7d0bec0
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=f7d0a000 task=f7d0f0e0)
Stack: e0f89480 f34d1800 f34d19e8 ffffff8f c030551d c02fdac6 000004ec f34d1800
        f34d19e8 f34d1864 f7d0bf3c c03079dd f665e080 00000001 f6085970 c2f96ce0
        f7d0bf30 00000292 6e704540 001112a0 00000001 f34d1800 1e6ef2b0 c2f976e0
Call Trace:
  [<c030551d>] tcp_retransmit_skb+0x1bd/0x310
  [<c02fdac6>] tcp_enter_loss+0x66/0x230
  [<c03079dd>] tcp_retransmit_timer+0xed/0x410
  [<c0307da9>] tcp_write_timer+0xa9/0xe0
  [<c0307d00>] tcp_write_timer+0x0/0xe0
  [<c0129124>] run_timer_softirq+0xd4/0x170
  [<c0125134>] __do_softirq+0xb4/0xc0
  [<c012516d>] do_softirq+0x2d/0x30
  [<c0117a3c>] smp_apic_timer_interrupt+0xdc/0x140
  [<c01079a6>] apic_timer_interrupt+0x1a/0x20
  [<c0105030>] default_idle+0x0/0x40
  [<c0105059>] default_idle+0x29/0x40
  [<c01050eb>] cpu_idle+0x3b/0x50
  [<c027e780>] serial8250_console_write+0x0/0x200
  [<c027e780>] serial8250_console_write+0x0/0x200
  [<c0121517>] __call_console_drivers+0x57/0x60
  [<c012160f>] call_console_drivers+0x7f/0x100

Code: 8b 02 a9 00 00 08 00 75 70 f0 ff 42 04 8b 85 a4 00 00 00 46
  <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing
  <0>Rebooting in 30 seconds..Press any key to continue.

Also found in logs (though few hours before the crash - not sure if related):
KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1568)
(...lots of times)

Steps to reproduce:
Nothing special except that it happened during relatively high network activity.

If I can be of any further help just let me know.

Thanks,

Ranko

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
