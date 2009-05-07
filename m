From: Panadero Pizza <panadero_pizza@yahoo.es>
Subject: Kernel networking problem (>=2.6.24.7)
Date: Thu, 7 May 2009 14:27:14 +0000 (GMT)
Message-ID: <153037.5500.qm@web28601.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web28601.mail.ukl.yahoo.com ([87.248.110.210]:26829 "HELO
	web28601.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751171AbZEGOd6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 10:33:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I encounter a strange Linux networking=20
problem that manifests on a x86 based embedded system (MOPS/520 of=20
kontron, http://www.mite.cz/embeddedmodulesfiles/pc104files/m_mops520_p=
489m124.pdf)=20
with DM9102A network card as (unfortunately) very seldom kernel panics =
and=20
warnings.
=20
The ("bad") kernels I tried till now are 2.6.24.7 and=20
2.6.27.12, configured with (among others) Elan Subarchitecture (X86_ELA=
N), CIFS,=20
TCP/IP (INET) and DMFE network driver.
=20
Kernel panics (and sometimes warnings) occur with these=20
kernels from a (user-space) software that writes (and flushes) data to =
a file on=20
a network CIFS handle (low data transmission rate). However I have neve=
r=20
received a kernel panic, writing data with a standard tool like =E2=80=9E=
dd if=3D/dev/zero=20
of=3D/mnt/cifs/test.dat=E2=80=9C using the same kernels, though writing=
 even huge amounts=20
of data (>10GB) at various data transmission rates (using different inp=
uts like=20
/dev/urandom, =E2=80=A6).
=20
All kernel traces have in common=20
that
 * they start with a write()-system call (the software=20
does only write)
 * the last common functions are always =E2=80=9Edev_queue_xmit=E2=80=9C=
=20
and =E2=80=9E__qdisc_run=E2=80=9C
 * the last function on the stack is always=20
different
 * the EIP does not point to a meaningful address (often=20
this address is a very small value: 0, 246, 1f8, =E2=80=A6), which coul=
d indicate a=20
stack problem=E2=80=A6
 The software which causes the bugs is a multi-threaded=20
program (pthreads), linked against uclibc, doing simply an fopen(=20
=E2=80=9C/mnt/cifs/datafile.dat=E2=80=9D, =E2=80=9Cwb=E2=80=9D ); then =
different putc(), puts(), fputc() (only=20
these 3 functions), mixed with fflushes() possibly from different tasks=
 and a=20
terminating fclose() =E2=80=93 but the bug must be in the=20
kernel=E2=80=A6=20
=20
Please find the kernel traces attached at the end of this=20
message.

A 2.6.16.62 Kernel, only configured with vital settings=20
(486 processor, ide driver and network driver set correctly) but everyt=
hing else=20
left to the default settings, seems to work now for days without any pr=
oblems=20
(though I don=E2=80=99t like to confirm this till now).
=20
I will continue to test further kernel set-ups =E2=80=93 but as=20
testing is very time consuming, I would also like to ask, if there is a=
nything I=20
could do, to further localize the problem?

Best regards,
David

Kernel Panic #1:
----------------

BUG: unable to handle kernel NULL pointer dereference at virtual addres=
s 000001f8
printing eip: 000001f8 *pde =3D 00000000
Oops: 0000 [#1] PREEMPT
Modules linked in:

Pid: 2730, comm: ellipse4 Not tainted (2.6.24.7 #68)
EIP: 0060:[<000001f8>] EFLAGS: 00010086 CPU: 0
EIP is at 0x1f8
EAX: 00000001 EBX: 00000009 ECX: 00000000 EDX: 00000086
ESI: c1d801c0 EDI: 00000086 EBP: c012d698 ESP: c1f759b0
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ellipse4 (pid: 2730, ti=3Dc1f74000 task=3Dc1e194c0 task.ti=3Dc1=
f74000)
Stack: c0339078 00000000 c01056cb c1fd2700 c0250536 c0267967 00000000 c=
0382170
       c1f0007b c1410000 ffffffff c0204637 c1c40060 00000297 c025ff50 c=
1c4e800
       00000246 c1f07598 c1c4eb40 c1c4e800 c1f07598 c1f07598 c1c4e800 c=
0254b69
Call Trace:
 [<c01056cb>] do_IRQ+0x55/0x68
 [<c0250536>] skb_release_all+0xa1/0xad
 [<c0267967>] ip_local_deliver+0xd7/0x169
 [<c0204637>] dmfe_start_xmit+0x161/0x196
 [<c025ff50>] __qdisc_run+0x61/0x185
 [<c0254b69>] dev_hard_start_xmit+0x193/0x1ec
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c01056cb>] do_IRQ+0x55/0x68
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c0256d89>] dev_queue_xmit+0x237/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c0267ea8>] ip_rcv+0x3cd/0x3f5
 [<c010bd98>] enqueue_task+0xa/0x14
 [<c0267adb>] ip_rcv+0x0/0x3f5
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c02abd9e>] schedule+0x214/0x257
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c012f496>] filemap_fdatawrite+0x23/0x27
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0107dd2>] restore_i387+0xe4/0xf8
 [<c0103250>] restore_sigcontext+0x115/0x17f
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code:  Bad EIP value.
EIP: [<000001f8>] 0x1f8 SS:ESP 0068:c1f759b0
Kernel panic - not syncing: Fatal exception in interrupt


Kernel Panic #2:
----------------

BUG: unable to handle kernel NULL pointer dereference at virtual addres=
s 00000000
printing eip: 00000000 *pde =3D 00000000
Oops: 0000 [#1] PREEMPT
Modules linked in:

Pid: 840, comm: ellipse4 Not tainted (2.6.24.7 #68)
EIP: 0060:[<00000000>] EFLAGS: 00010286 CPU: 0
EIP is at _stext+0x3feff000/0x14
EAX: 00000000 EBX: c1c3a800 ECX: 00010001 EDX: ffffff00
ESI: 00000000 EDI: 00000000 EBP: 00000000 ESP: c1fe7a10
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ellipse4 (pid: 840, ti=3Dc1fe6000 task=3Dc1886f90 task.ti=3Dc1f=
e6000)
Stack: c02564ae 00000000 c1ed96d8 00000000 c1c3a800 c1ed96d8 c1ed96d8 0=
000000e
       c025ff93 c1ed96d8 00000000 00000246 c1c3a800 000816a0 c1c3a800 c=
1ed96d8
       00000000 0000000e c0256c65 00000001 00000046 c1ed96d8 c1ee1164 c=
1e1a874
Call Trace:
 [<c02564ae>] net_tx_action+0xa6/0xc8
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c0256d89>] dev_queue_xmit+0x237/0x256
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c0103fe3>] common_interrupt+0x23/0x30
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c010c682>] enqueue_task_fair+0x16/0x24
 [<c01214e8>] hrtimer_wakeup+0x15/0x18
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c012d698>] handle_level_irq+0xb3/0xd0
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c010c352>] update_curr+0x52/0xc4
 [<c010c56f>] dequeue_entity+0xb/0x2a
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c02abd9e>] schedule+0x214/0x257
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c013a62e>] handle_mm_fault+0x1c0/0x508
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code:  Bad EIP value.
EIP: [<00000000>] _stext+0x3feff000/0x14 SS:ESP 0068:c1fe7a10
Kernel panic - not syncing: Fatal exception in interrupt

Kernel Panic #3:
----------------

Output of "top -b"
[...]
Mem: 28316K used, 1228K free, 0K shrd, 220K buff, 17476K cached
CPU: 17.6% usr  2.1% sys  0.0% nice 79.6% idle  0.0% io  0.1% irq  0.3%=
 softirq
Load average: 0.22 0.21 0.18
  PID  PPID USER     STAT   VSZ %MEM %CPU COMMAND
 1066  1060 root     S     8812 29.8 15.7 ellipse4
 1144   818 root     R     1248  4.2  2.3 top -b
 1090     2 root     SW<      0  0.0  1.1 [cifsd]
 1068  1060 root     S     8812 29.8  0.3 ellipse4
 1094  1060 root     S     8812 29.8  0.3 ellipse4
 1064  1060 root     S     8812 29.8  0.0 ellipse4
 1061  1060 root     S     8812 29.8  0.0 ellipse4
 1092  1060 root     S     8812 29.8  0.0 ellipse4
 1062  1060 root     S     8812 29.8  0.0 ellipse4
 1093  1060 root     S     8812 29.8  0.0 ellipse4
 1030  1028 root     S     8812 29.8  0.0 ellipse4
 1097  1060 root     S     8812 29.8  0.0 ellipse4
 1072  1060 root     S     8812 29.8  0.0 ellipse4
 1098  1060 root     S     8812 29.8  0.0 ellipse4
 1060  1030 root     S     8812 29.8  0.0 ellipse4
 1096  1060 root     S     8812 29.8  0.0 ellipse4
 1137  1060 root     S     8812 29.8  0.0 ellipse4
 1095  1060 root     S     8812 29.8  0.0 ellipse4
 1069  1060 root     S BUG: unable to handle kernel NULL pointer derefe=
rence at virtual address 00000246
printing eip: 00000246 *pde =3D 00000000
Oops: 0000 [#1] PREEMPT
Modules linked in:

Pid: 1094, comm: ellipse4 Not tainted (2.6.24.7 #68)
EIP: 0060:[<00000246>] EFLAGS: 00010206 CPU: 0
EIP is at 0x246
EAX: 000000c2 EBX: c038f6c0 ECX: 00000000 EDX: 000003fa
ESI: 00000000 EDI: c038f75c EBP: 00000000 ESP: c1dfb940
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ellipse4 (pid: 1094, ti=3Dc1dfa000 task=3Dc1f36530 task.ti=3Dc1=
dfa000)
Stack: 7ecb7ecb 000d0004 00000004 c038f690 c1e1781e 00000002 dd09bd01 3=
26ea8c0
       00000000 00000004 c012c3d4 c0338f60 00000004 c1d80160 00000004 c=
012d65c
       000000e0 c0338f60 00000000 c01056c6 00000009 c012c3d4 c0339078 0=
0000009
Call Trace:
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c012d65c>] handle_level_irq+0x77/0xd0
 [<c01056c6>] do_IRQ+0x50/0x68
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c012d698>] handle_level_irq+0xb3/0xd0
 [<c01056cb>] do_IRQ+0x55/0x68
 [<c0250536>] skb_release_all+0xa1/0xad
 [<c0204637>] dmfe_start_xmit+0x161/0x196
 [<c025ff50>] __qdisc_run+0x61/0x185
 [<c0254b69>] dev_hard_start_xmit+0x193/0x1ec
 [<c024fe46>] __kfree_skb+0x8/0x61
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c01056cb>] do_IRQ+0x55/0x68
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c0103fe3>] common_interrupt+0x23/0x30
 [<c024ecde>] __copy_skb_header+0x72/0xad
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c02546df>] netif_receive_skb+0x17a/0x1f1
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c0255f46>] net_rx_action+0x4f/0x110
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c02abd9e>] schedule+0x214/0x257
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c012f496>] filemap_fdatawrite+0x23/0x27
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c01f92ca>] transmit_chars+0x5f/0xc5
 [<c01fb241>] serial8250_interrupt+0x3d/0x134
 [<c0107dd2>] restore_i387+0xe4/0xf8
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code:  Bad EIP value.
EIP: [<00000246>] 0x246 SS:ESP 0068:c1dfb940
Kernel panic - not syncing: Fatal exception in interrupt


Warning #4:
-----------

WARNING: at include/net/dst.h:165 dst_release()
Pid: 840, comm: ellipse4 Not tainted 2.6.24.7 #68
 [<c02504d5>] skb_release_all+0x40/0xad
 [<c024fe46>] __kfree_skb+0x8/0x61
 [<c0204662>] dmfe_start_xmit+0x18c/0x196
 [<c025ff50>] __qdisc_run+0x61/0x185
 [<c0254b69>] dev_hard_start_xmit+0x193/0x1ec
 [<c024fe46>] __kfree_skb+0x8/0x61
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c01056cb>] do_IRQ+0x55/0x68
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c0103fe3>] common_interrupt+0x23/0x30
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c012305c>] update_wall_time+0x50e/0x667
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c012f496>] filemap_fdatawrite+0x23/0x27
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0107dd2>] restore_i387+0xe4/0xf8
 [<c0103250>] restore_sigcontext+0x115/0x17f
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Kernel Panic #5:
----------------

BUG: unable to handle kernel paging request at virtual address 00450008
printing eip: 00450008 *pde =3D 00000000
Oops: 0000 [#1] PREEMPT
Modules linked in:

Pid: 925, comm: ellipse4 Not tainted (2.6.24.7 #68)
EIP: 0060:[<00450008>] EFLAGS: 00010286 CPU: 0
EIP is at 0x450008
EAX: 00000000 EBX: c1c42800 ECX: 00010001 EDX: ffffff00
ESI: 6e921a00 EDI: e000bcf1 EBP: 8409204b ESP: c1e77a10
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ellipse4 (pid: 925, ti=3Dc1e76000 task=3Dc1c4b9f0 task.ti=3Dc1e=
76000)
Stack: c1d83bea c024fe46 c1c42800 c1c42800 c1c42800 c1fb7318 c1fb7318 0=
000000e
       c025ff93 001b7b36 00000000 c0382170 0000000a 001b7b36 c1c42800 c=
1fb7318
       00000000 0000000e c0256c65 00000001 00000046 c1fb7318 c1dff2a4 c=
0940074
Call Trace:
 [<c024fe46>] __kfree_skb+0x8/0x61
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c0103fe3>] common_interrupt+0x23/0x30
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c010c352>] update_curr+0x52/0xc4
 [<c010c56f>] dequeue_entity+0xb/0x2a
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c02abd9e>] schedule+0x214/0x257
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c012f496>] filemap_fdatawrite+0x23/0x27
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c010c65a>] enqueue_entity+0x2b/0x3d
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c01169cf>] run_timer_softirq+0x12/0x176
 [<c01252f7>] tick_handle_periodic+0xf/0x60
 [<c0103250>] restore_sigcontext+0x115/0x17f
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code:  Bad EIP value.
EIP: [<00450008>] 0x450008 SS:ESP 0068:c1e77a10
Kernel panic - not syncing: Fatal exception in interrupt



Kernel Panic #6:
----------------

BUG: unable to handle kernel NULL pointer dereference at virtual addres=
s 00000000
printing eip: 00000000 *pde =3D 00000000
Oops: 0000 [#1] PREEMPT
Modules linked in:

Pid: 840, comm: ellipse4 Not tainted (2.6.24.7 #68)
EIP: 0060:[<00000000>] EFLAGS: 00010286 CPU: 0
EIP is at _stext+0x3feff000/0x14
EAX: 00000000 EBX: c1c42800 ECX: 00010001 EDX: ffffff00
ESI: 00000000 EDI: 00000000 EBP: 00000000 ESP: c1fc7a10
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process ellipse4 (pid: 840, ti=3Dc1fc6000 task=3Dc1886f90 task.ti=3Dc1f=
c6000)
Stack: c02564ae 00000000 00000000 c1e71098 c1c42800 c1e71098 c1e71098 0=
000000e
       c025ff93 c1e71098 00000000 00000246 c1c42800 002684e4 c1c42800 c=
1e71098
       00000000 0000000e c0256c65 000853c6 c1e71098 c1e71098 c1e562e4 c=
0c0d874
Call Trace:
 [<c02564ae>] net_tx_action+0xa6/0xc8
 [<c025ff93>] __qdisc_run+0xa4/0x185
 [<c0256c65>] dev_queue_xmit+0x113/0x256
 [<c026adcd>] ip_finish_output+0x19d/0x1d5
 [<c026ba59>] ip_queue_xmit+0x2a0/0x2d4
 [<c012c3d4>] handle_IRQ_event+0x1a/0x3f
 [<c012d698>] handle_level_irq+0xb3/0xd0
 [<c027d94a>] tcp_v4_send_check+0x80/0xb6
 [<c0278f24>] tcp_transmit_skb+0x63a/0x66d
 [<c027a942>] __tcp_push_pending_frames+0x713/0x7c3
 [<c02505ad>] __alloc_skb+0x55/0x101
 [<c0270f5f>] tcp_sendmsg+0x912/0xa02
 [<c024b3a8>] sock_sendmsg+0xbb/0xd3
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c010c352>] update_curr+0x52/0xc4
 [<c010c56f>] dequeue_entity+0xb/0x2a
 [<c0102f71>] __switch_to+0xe1/0x108
 [<c02abd9e>] schedule+0x214/0x257
 [<c01b2e31>] allocate_mid+0x8d/0x14b
 [<c024c5ce>] kernel_sendmsg+0x27/0x35
 [<c01b368c>] SendReceive2+0x1ee/0x5f2
 [<c0130eac>] mempool_alloc+0x1c/0xd6
 [<c01a07db>] CIFSSMBWrite2+0x1a3/0x231
 [<c01adc78>] cifs_writepages+0x42f/0x5d3
 [<c01301c7>] __generic_file_aio_write_nolock+0x495/0x4f1
 [<c01ad849>] cifs_writepages+0x0/0x5d3
 [<c0133cab>] do_writepages+0x22/0x32
 [<c012f25e>] __filemap_fdatawrite_range+0x67/0x6e
 [<c0118c03>] dequeue_signal+0x1a/0x115
 [<c012f496>] filemap_fdatawrite+0x23/0x27
 [<c019cb12>] cifs_file_aio_write+0x36/0x3e
 [<c014925d>] do_sync_write+0xc6/0x109
 [<c011f0df>] autoremove_wake_function+0x0/0x35
 [<c0107dd2>] restore_i387+0xe4/0xf8
 [<c0103250>] restore_sigcontext+0x115/0x17f
 [<c0149197>] do_sync_write+0x0/0x109
 [<c01499e5>] vfs_write+0x8d/0x110
 [<c0149eab>] sys_write+0x43/0x69
 [<c0103d62>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code:  Bad EIP value.
EIP: [<00000000>] _stext+0x3feff000/0x14 SS:ESP 0068:c1fc7a10
Kernel panic - not syncing: Fatal exception in interrupt



Kernel 2.6.27.12 Panic #1:
--------------------------

[12046.358759] ------------[ cut here ]------------
[12046.360788] WARNING: at net/core/dst.c:265 dst_release+0x1f/0x25()
[12046.361725] Modules linked in:
[12046.362982] Pid: 427, comm: ellipse4 Not tainted 2.6.27.12 #1
[12046.364565]  [<c101409f>] warn_on_slowpath+0x41/0x65
[12046.366313]  [<c1003532>] ? sys_rt_sigreturn+0x95/0xd2
[12046.368257]  [<c1018299>] ? local_bh_enable+0x73/0x8a
[12046.370153]  [<c11c0fe7>] ? __nf_conntrack_find+0xcf/0xd8
[12046.372508]  [<c11c1f42>] ? nf_conntrack_in+0x332/0x386
[12046.375779]  [<c1018299>] ? local_bh_enable+0x73/0x8a
[12046.378735]  [<c11ac85c>] dst_release+0x1f/0x25
[12046.382106]  [<c11a45a8>] skb_release_all+0xe/0x88
[12046.384784]  [<c11a3f2b>] __kfree_skb+0xb/0x64
[12046.388058]  [<c11a3fac>] kfree_skb+0x28/0x2a
[12046.390164]  [<c115af48>] dmfe_start_xmit+0x1a4/0x1ae
[12046.392033]  [<c11a8f60>] dev_hard_start_xmit+0x1a0/0x1fc
[12046.394328]  [<c11b66f6>] __qdisc_run+0xb1/0x1b2
[12046.395752]  [<c11ab3a1>] dev_queue_xmit+0x2be/0x409
[12046.399770]  [<c11d326a>] ip_finish_output+0x1fd/0x235
[12046.402854]  [<c11d393a>] ip_output+0x9e/0xa5
[12046.404931]  [<c11d2d90>] ip_local_out+0x18/0x1b
[12046.407279]  [<c11d3b9d>] ip_queue_xmit+0x25c/0x2bc
[12046.408906]  [<c101b1ca>] ? run_timer_softirq+0x183/0x19d
[12046.411120]  [<c1017ca2>] ? _local_bh_enable+0x68/0x6a
[12046.413097]  [<c11e6813>] ? tcp_v4_send_check+0x7d/0xb7
[12046.415187]  [<c11e1c45>] tcp_transmit_skb+0x5ad/0x5e0
[12046.417154]  [<c11d85bd>] ? sk_stream_alloc_skb+0x27/0xb8
[12046.419387]  [<c11e32aa>] __tcp_push_pending_frames+0x60f/0x6ad
[12046.421204]  [<c11d9dd0>] tcp_sendmsg+0x7ea/0x8e1
[12046.423776]  [<c115abca>] ? dmfe_interrupt+0x41a/0x44a
[12046.426828]  [<c119f4dd>] sock_sendmsg+0xdd/0xf8
[12046.429197]  [<c1023acf>] ? autoremove_wake_function+0x0/0x33
[12046.430814]  [<c1006218>] ? pit_read+0x9e/0xcf
[12046.433029]  [<c1028f55>] ? getnstimeofday+0x4f/0xd2
[12046.434893]  [<c103ab8f>] ? mempool_alloc_slab+0xe/0x10
[12046.436998]  [<c103ac8e>] ? mempool_alloc+0x21/0xe4
[12046.438718]  [<c11a051c>] kernel_sendmsg+0x28/0x37
[12046.442368]  [<c10ed9b1>] SendReceive2+0x1cc/0x605
[12046.443910]  [<c10dcb56>] CIFSSMBWrite2+0x171/0x1fd
[12046.446787]  [<c10e89c9>] cifs_writepages+0x433/0x602
[12046.449785]  [<c1039d86>] ? __generic_file_aio_write_nolock+0x400/0x=
453
[12046.452402]  [<c10e8596>] ? cifs_writepages+0x0/0x602
[12046.455423]  [<c103de5d>] do_writepages+0x25/0x36
[12046.456880]  [<c1039004>] __filemap_fdatawrite_range+0x5d/0x65
[12046.459707]  [<c10391eb>] filemap_fdatawrite+0x15/0x17
[12046.462769]  [<c10d7d98>] cifs_file_aio_write+0x2e/0x37
[12046.464912]  [<c1054e38>] do_sync_write+0xaa/0xe8
[12046.467384]  [<c1010d5a>] ? task_tick_fair+0x1a/0x60
[12046.469135]  [<c1023acf>] ? autoremove_wake_function+0x0/0x33
[12046.470729]  [<c1026406>] ? run_hrtimer_pending+0xf4/0x10e
[12046.474165]  [<c1006218>] ? pit_read+0x9e/0xcf
[12046.476389]  [<c1103781>] ? security_file_permission+0xf/0x11
[12046.479150]  [<c1054d8e>] ? do_sync_write+0x0/0xe8
[12046.480723]  [<c1055557>] vfs_write+0x8f/0x10c
[12046.483985]  [<c10559cc>] sys_write+0x3d/0x62
[12046.486078]  [<c10038a2>] syscall_call+0x7/0xb
[12046.488253]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
[12046.489296] ---[ end trace 547e770951663424 ]---


     =20
