From: Andreas Steinmetz <ast@domdv.de>
Subject: 2.4.27 network related Oopses
Date: Sat, 18 Dec 2004 11:55:02 +0100
Message-ID: <41C40C86.80707@domdv.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050103020009060705080807"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050103020009060705080807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[please CC me on replies as I'm not subscribed]

Below are two somewhat similar Oopses from two different systems with an 
identical kernel configuration (attached) captured with netconsole. The 
kernel is a 2.4.27 with some patches. The Oopses happen not often (once 
every 4 to 8 weeks on average). They do have in common that they happen 
when there is lots of disk I/O and network I/O.
============================================================================
ksymoops 2.4.9 on i686 2.4.27.  Options used
      -V (default)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.27/ (default)
      -m /boot/System.map (specified)

Oops: 0002
CPU:    0
EIP:    0010:[<c013ddc1>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010013
eax: 000ff0c4   ebx: ffffffff   ecx: f7d22140   edx: 00000000
esi: c1c0f6a8   edi: 00000286   ebp: cc98d020   esp: ed541bac
ds: 0018   es: 0018   ss: 0018
Process cut (pid: 25393, stackpage=ed541000)
cc31f3c0
0025ca70
0000c98d
e1b55a40
00000003
e1b55aa0
cc98d020
c02f1ea3
cc98d000
00000358
e1b55a40
c02f1ff9
e1b55a40
00000202
fffffff4
c0332733
e1b55a40
c05f6290
cc98d020
e1b55a40
00000006
e1b55a40
cc98d020
c0332849
Call Trace:
  [<c02f1ea3>]
  [<c02f1ff9>]
  [<c0332733>]
  [<c0332849>]
  [<c0313831>]
  [<c02fe903>]
  [<c0313760>]
  [<c03132e4>]
  [<c0313760>]
  [<c0313ab9>]
  [<c03138d0>]
  [<c02fe903>]
  [<c03138d0>]
  [<c03136cb>]
Warning (Oops_read): Code line not seen, dumping what data is available


 >>EIP; c013ddc1 <kfree+51/d0>   <=====

 >>ecx; f7d22140 <_end+376713c8/38275308>
 >>esi; c1c0f6a8 <_end+155e930/38275308>
 >>ebp; cc98d020 <_end+c2dc2a8/38275308>
 >>esp; ed541bac <_end+2ce90e34/38275308>

Trace; c02f1ea3 <kfree_skbmem+13/70>
Trace; c02f1ff9 <__kfree_skb+f9/150>
Trace; c0332733 <raw_rcv_skb+93/170>
Trace; c0332849 <raw_rcv+39/60>
Trace; c0313831 <ip_local_deliver_finish+d1/170>
Trace; c02fe903 <nf_hook_slow+b3/180>
Trace; c0313760 <ip_local_deliver_finish+0/170>
Trace; c03132e4 <ip_local_deliver+1a4/1d0>
Trace; c0313760 <ip_local_deliver_finish+0/170>
Trace; c0313ab9 <ip_rcv_finish+1e9/270>
Trace; c03138d0 <ip_rcv_finish+0/270>
Trace; c02fe903 <nf_hook_slow+b3/180>
Trace; c03138d0 <ip_rcv_finish+0/270>
Trace; c03136cb <ip_rcv+3bb/450>


1 warning issued.  Results may not be reliable.
================================================================================
ksymoops 2.4.9 on i686 2.4.27.  Options used
      -V (default)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.27/ (default)
      -m /boot/System.map (specified)

Oops: 0002
CPU:    0
EIP:    0010:[<c013ddc1>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010013
eax: 000e5896   ebx: ffffffff   ecx: f7d22240   edx: 00000000
esi: c1c0f6a8   edi: 00000286   ebp: c6626020   esp: d373bbac
ds: 0018   es: 0018   ss: 0018
Process userupdate.cvs (pid: 10934, stackpage=d373b000)
f5e16780
00132720
00006626
f670f600
00000003
f670f660
c6626020
c02f1ea3
c6626000
00000358
f670f600
c02f1ff9
f670f600
00000202
fffffff4
c0332733
f670f600
c05f6290
c6626020
f670f600
00000006
f670f600
c6626020
c0332849
Call Trace:
  [<c02f1ea3>]
  [<c02f1ff9>]
  [<c0332733>]
  [<c0332849>]
  [<c0313831>]
  [<c02fe903>]
  [<c0313760>]
  [<c03132e4>]
  [<c0313760>]
  [<c0313ab9>]
  [<c03138d0>]
  [<c02fe903>]
  [<c03138d0>]
Warning (Oops_read): Code line not seen, dumping what data is available


 >>EIP; c013ddc1 <kfree+51/d0>   <=====

 >>ecx; f7d22240 <_end+376714c8/38275308>
 >>esi; c1c0f6a8 <_end+155e930/38275308>
 >>ebp; c6626020 <_end+5f752a8/38275308>
 >>esp; d373bbac <_end+1308ae34/38275308>

Trace; c02f1ea3 <kfree_skbmem+13/70>
Trace; c02f1ff9 <__kfree_skb+f9/150>
Trace; c0332733 <raw_rcv_skb+93/170>
Trace; c0332849 <raw_rcv+39/60>
Trace; c0313831 <ip_local_deliver_finish+d1/170>
Trace; c02fe903 <nf_hook_slow+b3/180>
Trace; c0313760 <ip_local_deliver_finish+0/170>
Trace; c03132e4 <ip_local_deliver+1a4/1d0>
Trace; c0313760 <ip_local_deliver_finish+0/170>
Trace; c0313ab9 <ip_rcv_finish+1e9/270>
Trace; c03138d0 <ip_rcv_finish+0/270>
Trace; c02fe903 <nf_hook_slow+b3/180>
Trace; c03138d0 <ip_rcv_finish+0/270>


1 warning issued.  Results may not be reliable.

-- 
Andreas Steinmetz                       SPAMmers use robotrap@domdv.de

--------------050103020009060705080807
Content-Type: application/x-gunzip;
 name="config.gz"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="config.gz"

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
--------------050103020009060705080807--
