From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 32322] New: Kernel crashes randomly due to unknown reason
Date: Thu, 31 Mar 2011 08:45:30 -0700
Message-ID: <20110331084530.187c9145@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53304 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751762Ab1CaPpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 11:45:34 -0400
Received: from nehalam (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.14.2/Debian-2build1) with ESMTP id p2VFjVe1024096
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 08:45:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 31 Mar 2011 08:22:53 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 32322] New: Kernel crashes randomly due to unknown reason


https://bugzilla.kernel.org/show_bug.cgi?id=32322

           Summary: Kernel crashes randomly due to unknown reason
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.37.2
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: henrick19777@yahoo.com
        Regression: No


Created an attachment (id=52732)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=52732)
kernel config file

Got a second kernel panic on this machine just randomly after ~26 days of
uptime. This server runs Debian Squeeze with vsftpd, rsync and apache2 services
installed from repositories. Here is the crash log:

 ------------[ cut here ]------------
kernel BUG at net/ipv4/tcp_output.c:994!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:05/0000:05:07.1/local_cpus
Modules linked in:

Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-hid3 #2 IBM eserver xSeries 235
-
[8671MAX]-/
EIP: 0060:[<c11c7f53>] EFLAGS: 00010206 CPU: 3
EIP is at tcp_fragment+0x15/0x239
EAX: c039ee00 EBX: f40e1200 ECX: 00003de0 EDX: f40e1200
ESI: f40e1200 EDI: c039ee00 EBP: 00003880 ESP: f50b7dd8
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process kworker/0:1 (pid: 0, ti=f50b6000 task=f50b1bc0 task.ti=f50b2000)
Stack:
 00003de0 00000286 c102841f c039ee00 f40e1200 f40e1218 00000023 c11c132d
 000005a0 00000000 00000002 c039ee7c 00000001 c039ee00 0000072e 00000000
 c11c57f6 00000001 00000001 00000000 00000001 00000026 00000006 c039ee7c
Call Trace:
 [<c102841f>] ? __mod_timer+0xe3/0xec
 [<c11c132d>] ? tcp_mark_head_lost+0x100/0x1a4
 [<c11c57f6>] ? tcp_ack+0x154e/0x1813
 [<c11c5e91>] ? tcp_rcv_established+0x3d6/0x48c
 [<c11cb836>] ? tcp_v4_do_rcv+0x4a/0x1ad
 [<c11cc64d>] ? tcp_v4_rcv+0x2dc/0x4cb
 [<c11bd022>] ? tcp_gro_receive+0x84/0x1dd
 [<c11b57e5>] ? ip_local_deliver+0x75/0x102
 [<c11b572b>] ? ip_rcv+0x477/0x4bc
 [<c11a0b80>] ? __netif_receive_skb+0x238/0x25a
 [<c1006084>] ? nommu_sync_single_for_device+0x0/0x1
 [<c11a11ab>] ? netif_receive_skb+0x5a/0x5f
 [<c11a1253>] ? napi_skb_finish+0x1b/0x30
 [<c116fce3>] ? tg3_poll_work+0x587/0x99f
 [<c1170202>] ? tg3_poll+0x84/0x17d
 [<c11a1680>] ? net_rx_action+0x53/0x12b
 [<c1024503>] ? __do_softirq+0x70/0xfb
 [<c1024493>] ? __do_softirq+0x0/0xfb
 <IRQ>
 [<c10243ed>] ? irq_exit+0x26/0x59
 [<c100389d>] ? do_IRQ+0x7a/0x8b
 [<c1002b29>] ? common_interrupt+0x29/0x30
 [<c100764c>] ? default_idle+0x2b/0x3e
 [<c10019f0>] ? cpu_idle+0x41/0x5d
Code: e8 33 ed ff ff 89 da 89 c1 89 f0 e8 6d e9 ff ff 31 c0 5b 5e 5f c3 55 57
89 c7 56 53 89 d3 83 ec 0c 89 0c 24 8b 6a 4c 39 e9 76 04 <0f> 0b eb fe f6 42 60
02 8b 72 50 74 27 8b 82 8c 00 00 00 8b 40
EIP: [<c11c7f53>] tcp_fragment+0x15/0x239 SS:ESP 0068:f50b7dd8
---[ end trace 2c2c1c63c61b172d ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: kworker/0:1 Tainted: G      D     2.6.37.2-hid3 #2
Call Trace:
 [<c11eb2ac>] ? panic+0x4d/0x130
 [<c1002e8e>] ? do_invalid_op+0x0/0x70
 [<c1004a7d>] ? oops_end+0x6b/0x75
 [<c1002ef5>] ? do_invalid_op+0x67/0x70
 [<c11c7f53>] ? tcp_fragment+0x15/0x239
 [<c11c0be2>] ? tcp_shifted_skb+0x1e7/0x200
 [<c11c1699>] ? tcp_sacktag_walk+0x210/0x3a7
 [<c11ecfee>] ? error_code+0x5a/0x60
 [<c1002e8e>] ? do_invalid_op+0x0/0x70
 [<c11c7f53>] ? tcp_fragment+0x15/0x239
 [<c102841f>] ? __mod_timer+0xe3/0xec
 [<c11c132d>] ? tcp_mark_head_lost+0x100/0x1a4
 [<c11c57f6>] ? tcp_ack+0x154e/0x1813
 [<c11c5e91>] ? tcp_rcv_established+0x3d6/0x48c
 [<c11cb836>] ? tcp_v4_do_rcv+0x4a/0x1ad
 [<c11cc64d>] ? tcp_v4_rcv+0x2dc/0x4cb
 [<c11bd022>] ? tcp_gro_receive+0x84/0x1dd
 [<c11b57e5>] ? ip_local_deliver+0x75/0x102
 [<c11b572b>] ? ip_rcv+0x477/0x4bc
 [<c11a0b80>] ? __netif_receive_skb+0x238/0x25a
 [<c1006084>] ? nommu_sync_single_for_device+0x0/0x1
 [<c11a11ab>] ? netif_receive_skb+0x5a/0x5f
 [<c11a1253>] ? napi_skb_finish+0x1b/0x30
 [<c116fce3>] ? tg3_poll_work+0x587/0x99f
 [<c1170202>] ? tg3_poll+0x84/0x17d
 [<c11a1680>] ? net_rx_action+0x53/0x12b
 [<c1024503>] ? __do_softirq+0x70/0xfb
 [<c1024493>] ? __do_softirq+0x0/0xfb
 <IRQ>  [<c10243ed>] ? irq_exit+0x26/0x59
 [<c100389d>] ? do_IRQ+0x7a/0x8b
 [<c1002b29>] ? common_interrupt+0x29/0x30
 [<c100764c>] ? default_idle+0x2b/0x3e
 [<c10019f0>] ? cpu_idle+0x41/0x5d
Rebooting in 20 seconds..


# cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Xeon(TM) CPU 3.06GHz
stepping        : 9
cpu MHz         : 3060.475
cache size      : 512 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 1
apicid          : 0
initial apicid  : 0
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pebs bts cid xtpr
bogomips        : 6120.95
clflush size    : 64
cache_alignment : 128
address sizes   : 36 bits physical, 32 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Xeon(TM) CPU 3.06GHz
stepping        : 9
cpu MHz         : 3060.475
cache size      : 512 KB
physical id     : 3
siblings        : 2
core id         : 0
cpu cores       : 1
apicid          : 6
initial apicid  : 6
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pebs bts cid xtpr
bogomips        : 6120.36
clflush size    : 64
cache_alignment : 128
address sizes   : 36 bits physical, 32 bits virtual
power management:

processor       : 2
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Xeon(TM) CPU 3.06GHz
stepping        : 9
cpu MHz         : 3060.475
cache size      : 512 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 1
apicid          : 1
initial apicid  : 1
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pebs bts cid xtpr
bogomips        : 6120.33
clflush size    : 64
cache_alignment : 128
address sizes   : 36 bits physical, 32 bits virtual
power management:

processor       : 3
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Xeon(TM) CPU 3.06GHz
stepping        : 9
cpu MHz         : 3060.475
cache size      : 512 KB
physical id     : 3
siblings        : 2
core id         : 0
cpu cores       : 1
apicid          : 7
initial apicid  : 7
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pebs bts cid xtpr
bogomips        : 6120.41
clflush size    : 64
cache_alignment : 128
address sizes   : 36 bits physical, 32 bits virtual
power management:


uname -a:
Linux debian 2.6.37.2-hid3 #2 SMP Wed Mar 2 23:34:19 EET 2011 i686 GNU/Linux

NO modules loaded.

The hardware is IBM eserver xSeries 235 - [8671MAX]-/


dmesg output and custom kernel config are attached.

THe crash happens randomly.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
