From: "Andrey J. Melnikoff (TEMHOTA)" <temnota@kmv.ru>
Subject: Re: Fw: [Bugme-new] [Bug 1054] New: loading iptables modules kill raid5 kernel thread
Date: Tue, 12 Aug 2003 23:07:10 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812190710.GQ14564@kmv.ru>
References: <20030807085043.3b794387.akpm@osdl.org> <20030812172855.43BB22C06E@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, laforge@gnumonks.org,
   mingo@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <20030812172855.43BB22C06E@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Rusty Russell!
 On Tue, Aug 12, 2003 at 07:26:47AM +1000, Rusty Russell wrote next:

> In message <20030807085043.3b794387.akpm@osdl.org> you write:
> > 
> > This is weird.  It looks like something on the netfilter module
> > initialisation path has called smp_call_function(garbage_address).  But I
> > cannot see where anything like that could happen.
> 
> Hmm, this is 2.4.  Is this a regression against previous kernels?
> 
> I can't see anything to suspect here: we certainly don't use
> smp_call_function in the netfilter code.  I wonder if loading a
> different module causes the same problems.
No, only iptables loaded as modules, all other in kernel.
 
> BTW xor.h declares non-inline functions which I find disturbing.  Hmm,
> maybe that tricky asm xor stuff blatts something which the
> smp_call_function wants to use...?

Maybe. I see to many calls to flush_tlb_all_ipi when iptables start. See
log (i'm add to smp_call_function_interrupt simple printk to see what
function it call)

# /etc/rc.d/rc.ipables start
Arno's IPTABLES (ADSL) Firewall / NAT script v1.7.1BETA-1
---------------------------------------------------------------
Checking for root privileges...OK

External (internet) interface (EXT_IF)   : eth+
IPTABLES module / kernel check...
Detected IPTABLES module... Loading additional IPTABLES modules:
ip_tables: (C) 2000-2002 Netfilter core team
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
All IPTABLES modules loaded!

---------------------------------------------------------------
Flushing rules in the filter table
iptables -F
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -X
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -Z
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -F INPUT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -F OUTPUT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -F FORWARD
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -X CHECK
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -X VALID_CHECK
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -t mangle -F
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -t mangle -X
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -t mangle -Z
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
Setting default secure policies
iptables -P INPUT DROP
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -P FORWARD DROP
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -P OUTPUT ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -t mangle -P OUTPUT ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -t mangle -P PREROUTING ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -N CHECK
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -N VALID_CHECK
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -N acct_in
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -N acct_out
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -N acct_forw
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A INPUT -j acct_in
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A OUTPUT -j acct_out
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A FORWARD -j acct_forw
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A FORWARD -i eth1 -j ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A FORWARD -o eth1 -j ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A INPUT -i eth1 -p udp --dport 67 -j ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
iptables -A INPUT -i eth1 -p udp --dport 53 -j ACCEPT
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1
SCFI call fn=c0113b20 in=00000000 wa=1

Unable to handle kernel NULL pointer dereference at virtual address 000000aa
c102c024
*pde = 00000000
Oops: 0002
CPU:    1
EIP:    0010:[<c102c024>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010086
eax: 000000aa   ebx: c02b2080   ecx: 00000000   edx: d141a000
esi: c102c01c   edi: 00003c8a   ebp: d1d93ddc   esp: d1d93db8
ds: 0018   es: 0018   ss: 0018
Process raid5d (pid: 13, stackpage=d1d93000)
Stack: c0113df7 c02b2080 c0270160 c0113b20 00000000 00000001 d1b0f500 00000057
       d1b0f000 d1d93e20 c010ccea d1b0f500 d1b10500 d1b0e500 00000057 d1b0f000
       d1d93e20 32203931 00000018 00000018 fffffffb c01fedc9 00000010 00000202
Call Trace:    [<c0113df7>] [<c0113b20>] [<c010ccea>] [<c01fedc9>] [<c01ff462>]
  [<c01fa55e>] [<c01fb731>] [<c01fbf9f>] [<c01fbec0>] [<c0203bcc>] [<c0105883>]
  [<c0203a30>] [<c0203a30>]
Code: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 01

>>EIP; c102c024 <END_OF_CODE+ca9904/????>   <=====

>>ebx; c02b2080 <contig_page_data+e0/360>

Trace; c0113df7 <smp_call_function_interrupt+47/65>
Trace; c0113b20 <flush_tlb_all_ipi+0/60>
Trace; c010ccea <call_call_function_interrupt+5/b>
Trace; c01fedc9 <xor_8regs_3+19/70>
Trace; c01ff462 <xor_block+92/b0>
Trace; c01fa55e <compute_block+8e/e0>
Trace; c01fb731 <handle_stripe+cd1/1000>
Trace; c01fbf9f <raid5d+df/1f0>
Trace; c01fbec0 <raid5d+0/1f0>
Trace; c0203bcc <md_thread+19c/2a0>
Trace; c0105883 <arch_kernel_thread+23/30>
Trace; c0203a30 <md_thread+0/2a0>
Trace; c0203a30 <md_thread+0/2a0>

Code;  c102c024 <END_OF_CODE+ca9904/????>   <=====
00000000 <_EIP>:   <=====
Code;  c102c034 <END_OF_CODE+ca9914/????>
  10:   00 40 00                  add    %al,0x0(%eax)
Code;  c102c037 <END_OF_CODE+ca9917/????>
  13:   01 00                     add    %eax,(%eax)

but system still alive, iptables process get stuck in "Running" state

....
Call Trace:    [<c0120585>] [<c0107863>]
bash          S 00000007  5100   644    643   681               (NOTLB)
Call Trace:    [<c0120585>] [<c0107863>]
rc.iptables   S BFFFB200   240   681    644   761               (NOTLB)
Call Trace:    [<c0120585>] [<c0107863>]
iptables1     S BFFFF680  4284   761    681   762               (NOTLB)
Call Trace:    [<c0120585>] [<c0107863>]
iptables      R 00000041     0   762    761                     (NOTLB)
Call Trace:    [<c020daa0> sys_socketcall+150] [<c0107863> system_call+33]
...

Strange..... Stack frame - with invalid order... 

-- 
 Best regards, TEMHOTA-RIPN aka MJA13-RIPE
 System Administrator. mailto:temnota@kmv.ru
