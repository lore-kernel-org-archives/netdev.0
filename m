From: Adam Wozniak <awozniak@comdev.cc>
Subject: ipv4 problem w/ eepro100 drivers
Date: Mon, 10 Jun 2002 17:01:48 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0206101656220.31336-100000@rangers.comdev.cc>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <davem@redhat.com>, <ak@muc.de>, <kuznet@ms2.inr.ac.ru>,
   <pekkas@netcore.fi>, <netdev@oss.sgi.com>, <saw@saw.sw.com.sg>
List-Id: netdev.vger.kernel.org

On a machine with an 82559ER ethernet chip
Linux 2.5.5, with the 6/5/2002 eepro100.c

Connect to some other machine via a crossover cable

run iperf as a server on both machines
run iperf as a client to the server on the other machine

(i.e. we want an isolated network, full duplex, full traffic in both directions)

[awozniak@rangers ~/linux-2.5.5]$ ksymoops -VKOL -m System239.map < oops239.txt
ksymoops 2.4.0 on i686 2.4.2-2.  Options used
     -V (specified)
     -K (specified)
     -L (specified)
     -O (specified)
     -m System239.map (specified)

Unable to handle kernel paging request at virtual address 3938377f
c01d1716
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<c01d1716>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010217
eax: cdc42a08   ebx: 39383736   ecx: 00000004   edx: 00000000
esi: cdc42b10   edi: cdc429a0   ebp: 00000009   esp: c0251ef0
ds: 0018   es: 0018   ss: 0018
Stack: cdc429a0 cdc42b10 cdc42a08 cdc429a0 c01d9dee cdc429a0 00000000 cda8e5c0
       00000000 00000001 00000000 cdc429a0 0000e8c8 00000000 00000046 c01d9fc6
       cdc429a0 00000001 00000000 c0251fac 00000000 cdc429a0 c01d9f20 c011a933
Call Trace: [<c01d9dee>] [<c01d9fc6>] [<c01d9f20>] [<c011a933>] [<c011779b>]
   [<c01176a4>] [<c01174cb>] [<c0109eac>] [<c0106cc0>] [<c0106cc0>] [<c0106cc0>]
   [<c0106cc0>] [<c0106ce4>] [<c0106d62>] [<c0105000>]
Code: 0f b6 4b 49 45 f6 c1 82 74 0c 31 d2 89 96 70 01 00 00 0f b6

>>EIP; c01d1716 <tcp_enter_loss+c6/1a0>   <=====
Trace; c01d9dee <tcp_retransmit_timer+17e/2b0>
Trace; c01d9fc6 <tcp_write_timer+a6/f0>
Trace; c01d9f20 <tcp_write_timer+0/f0>
Trace; c011a933 <timer_bh+213/250>
Trace; c011779b <bh_action+1b/50>
Trace; c01176a4 <tasklet_hi_action+44/70>
Trace; c01174cb <do_softirq+4b/90>
Trace; c0109eac <do_IRQ+9c/b0>
Trace; c0106cc0 <default_idle+0/30>
Trace; c0106cc0 <default_idle+0/30>
Trace; c0106cc0 <default_idle+0/30>
Trace; c0106cc0 <default_idle+0/30>
Trace; c0106ce4 <default_idle+24/30>
Trace; c0106d62 <cpu_idle+32/50>
Trace; c0105000 <_stext+0/0>
Code;  c01d1716 <tcp_enter_loss+c6/1a0>
00000000 <_EIP>:
Code;  c01d1716 <tcp_enter_loss+c6/1a0>   <=====
   0:   0f b6 4b 49               movzbl 0x49(%ebx),%ecx   <=====
Code;  c01d171a <tcp_enter_loss+ca/1a0>
   4:   45                        inc    %ebp
Code;  c01d171b <tcp_enter_loss+cb/1a0>
   5:   f6 c1 82                  test   $0x82,%cl
Code;  c01d171e <tcp_enter_loss+ce/1a0>
   8:   74 0c                     je     16 <_EIP+0x16> c01d172c
<tcp_enter_loss+dc/1a0>
Code;  c01d1720 <tcp_enter_loss+d0/1a0>
   a:   31 d2                     xor    %edx,%edx
Code;  c01d1722 <tcp_enter_loss+d2/1a0>
   c:   89 96 70 01 00 00         mov    %edx,0x170(%esi)
Code;  c01d1728 <tcp_enter_loss+d8/1a0>
  12:   0f b6 00                  movzbl (%eax),%eax

  <0> Kernel panic: Aiee, killing interrupt handler!
[awozniak@rangers ~/linux-2.5.5]$

-- 
Adam Wozniak (KG6GZR)   COM DEV Broadband - Digital and Software Systems
awozniak@comdev.cc      805 Aerovista Place, San Luis Obispo, CA 93401
                        http://www.comdev.cc
                        Voice: (805) 544-1089       Fax: (805) 544-2055
