From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3756] New: oops during raid rebuild (ServeRAID
 6M)
Date: Wed, 17 Nov 2004 01:29:02 -0800
Message-ID: <20041117012902.7deecd8e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: janfrode@parallab.uib.no
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


That's a networking bug, not a scsi bug.


Begin forwarded message:

Date: Wed, 17 Nov 2004 01:19:59 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3756] New: oops during raid rebuild (ServeRAID 6M)


http://bugme.osdl.org/show_bug.cgi?id=3756

           Summary: oops during raid rebuild (ServeRAID 6M)
    Kernel Version: 2.6.9
            Status: NEW
          Severity: high
             Owner: andmike@us.ibm.com
         Submitter: janfrode@parallab.uib.no


Distribution: CentOS 3.3
Hardware Environment: Dell PowerEdge 2650, 2x Pentium Xeon, 4 GB memory, IBM
ServeRAID 6M
Software Environment:

Plain 2.6.9 kernel, plus updated ips driver for the ServeRAID adapter. ips v7.10.18.

Problem Description:

I have a 2-node cluster using IBM ServeRAID 6M with linux 2.6.9 +
version 7.10.18 of the ips driver (I'll add the sources to this bug report). 
Today I tested removing one of the drives in the mirrored volumes. That seemed
to work fine. Then I inserted the drive again, and RAID rebuild was
automatically started. After a few seconds I got the following oops:

---------------------------------------------------------
------------[ cut here ]------------
kernel BUG at net/ipv4/tcp_output.c:277!
invalid operand: 0000 [#1]
SMP
Modules linked in: mptctl mptbase lp sk98lin ipv6 tg3 ipt_REJECT ipt_state
ip_conntrack iptable_filter ip_tables aacraid ips
CPU:    2
EIP:    0060:[<c0384aeb>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9ips)
EIP is at tcp_transmit_skb+0x87b/0x892
eax: f7859d00   ebx: 0000400c   ecx: 00000020   edx: f6ce5c80
esi: db7ec274   edi: db7ec274   ebp: f7f66ea8   esp: dda0dda8
ds: 007b   es: 007b   ss: 0068
Process java (pid: 4680, threadinfo=dda0c000 task=f78d8030)
Stack: 00000000 f7b97680 db7ec0e4 00000246 f6ce5c80 f7b97680 db7ec0e4 00000020
       f6ce5cb8 db7ec1dc f6ce5c80 db7ec080 0000400c db7ec274 db7ec080 f7f66ea8
       c0383633 00000000 00000000 00000000 c2e419c0 dda0de28 00000218 f6641580
Call Trace:
 [<c0383633>] tcp_rcv_synsent_state_process+0x50c/0x561
 [<c0383fc0>] tcp_rcv_state_process+0x938/0xa1c
 [<c038b72f>] tcp_v4_do_rcv+0x8a/0x10e
 [<c03547ce>] __release_sock+0x3e/0x58
 [<c0354e42>] release_sock+0x6e/0x70
 [<c03994e0>] inet_wait_for_connect+0x7d/0xd1
 [<c011a0a0>] autoremove_wake_function+0x0/0x43
 [<c011a0a0>] autoremove_wake_function+0x0/0x43
 [<f89943f6>] inet6_bind+0x103/0x2de [ipv6]
 [<c03995fc>] inet_stream_connect+0xc8/0x187
 [<c0352aec>] sys_connect+0x74/0xa0
 [<c0351709>] sock_map_fd+0x124/0x13a
 [<c035254a>] __sock_create+0xe0/0x221
 [<c0258cdd>] copy_from_user+0x54/0x83
 [<c035345a>] sys_socketcall+0x9c/0x24b
 [<c011fd81>] sys_gettimeofday+0x24/0x5f
 [<c0105a8f>] syscall_call+0x7/0xb
Code: ff ff 7f e9 74 f8 ff ff 0f b6 87 3f 01 00 00 84 c0 0f 84 5b f8 ff ff 8b 54
24 1c 0f b6 c0 8d 54 c2 04 89 54 24 1c e9 47 f8 ff ff <0f> 0b 15 01 5a 00 41 c0
e9 cc f7 ff ff b
 ------------[ cut here ]------------
Kernel panic - not syncing: Fatal exception in interrupt
 <1>kernel BUG at net/ipv4/tcp_output.c:277!
invalid operand: 0000 [#2]
SMP
Modules linked in: mptctl mptbase lp sk98lin ipv6 tg3 ipt_REJECT ipt_state
ip_conntrack iptable_filter ip_tables aacraid ips
CPU:    1
EIP:    0060:[<c0384aeb>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9ips)
EIP is at tcp_transmit_skb+0x87b/0x892
eax: f7f69900   ebx: 0000400c   ecx: 00000020   edx: f7b64d80
esi: db7ec774   edi: db7ec774   ebp: f7f356a8   esp: dda0fda8
ds: 007b   es: 007b   ss: 0068
Process java (pid: 4661, threadinfo=dda0e000 task=c748b930)
Stack: 00000000 f6ce4380 db7ec5e4 00000246 f7b64d80 f6ce4380 db7ec5e4 00000020
       f7b64db8 db7ec6dc f7b64d80 db7ec580 0000400c db7ec774 db7ec580 f7f356a8
       c0383633 00000000 00000000 00000000 c2e399c0 dda0fe28 00000218 f73dc380
Call Trace:
 [<c0383633>] tcp_rcv_synsent_state_process+0x50c/0x561
 [<c0383fc0>] tcp_rcv_state_process+0x938/0xa1c
 [<c038b72f>] tcp_v4_do_rcv+0x8a/0x10e
 [<c03547ce>] __release_sock+0x3e/0x58
 [<c0354e42>] release_sock+0x6e/0x70
 [<c03994e0>] inet_wait_for_connect+0x7d/0xd1
 [<c011a0a0>] autoremove_wake_function+0x0/0x43
 [<c011a0a0>] autoremove_wake_function+0x0/0x43
 [<f89943f6>] inet6_bind+0x103/0x2de [ipv6]
 [<c03995fc>] inet_stream_connect+0xc8/0x187
 [<c0352aec>] sys_connect+0x74/0xa0
 [<c0351709>] sock_map_fd+0x124/0x13a
 [<c035254a>] __sock_create+0xe0/0x221
 [<c0258cdd>] copy_from_user+0x54/0x83
 [<c035345a>] sys_socketcall+0x9c/0x24b
 [<c011fd81>] sys_gettimeofday+0x24/0x5f
 [<c0105a8f>] syscall_call+0x7/0xb
Code: ff ff 7f e9 74 f8 ff ff 0f b6 87 3f 01 00 00 84 c0 0f 84 5b f8 ff ff 8b 54
24 1c 0f b6 c0 8d 54 c2 04 89 54 24 1c e9 47 f8 ff ff <0f> 0b 15 01 5a 00 41 c0
e9 cc f7 ff ff b
Badness in do_unblank_screen at drivers/char/vt.c:2871
 [<c0284464>] do_unblank_screen+0x13d/0x142
 [<c0115464>] bust_spinlocks+0x28/0x50
 [<c0106c21>] die+0xfe/0x173
 [<c0107002>] do_invalid_op+0x0/0xed
 [<c0107002>] do_invalid_op+0x0/0xed
 [<c01070ed>] do_invalid_op+0xeb/0xed                                          
                                                                               
               
---------------------------------------------------------

and the machine seemed dead according to heartbeat, so the other node
took over. This node also quickly failed with the following oops:
                                                                               
                                                         
---------------------------------------------------------
------------[ cut here ]------------
kernel BUG at net/ipv4/tcp_output.c:277!
invalid operand: 0000 [#1]
SMP
Modules linked in: lp mptctl mptbase ipv6 tg3 ipt_REJECT ipt_state ip_conntrack
iptable_filter ip_tables aacraid ips
CPU:    2
EIP:    0060:[<c0384aeb>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9ips)
EIP is at tcp_transmit_skb+0x87b/0x892
eax: c2f3eb00   ebx: 0000400c   ecx: 00000020   edx: ed162680
esi: ed546774   edi: ed546774   ebp: c2f3e8a8   esp: ed7a7da8
ds: 007b   es: 007b   ss: 0068
Process java (pid: 3323, threadinfo=ed7a6000 task=ed06a810)
Stack: 00000000 ed162080 ed5465e4 00000246 ed162680 ed162080 ed5465e4 00000020
       ed1626b8 ed5466dc ed162680 ed546580 0000400c ed546774 ed546580 c2f3e8a8
       c0383633 00000000 00000000 00000000 c2e419c0 ed7a7e28 00000218 f7b99680
Call Trace:
 [<c0383633>] tcp_rcv_synsent_state_process+0x50c/0x561
 [<c0383fc0>] tcp_rcv_state_process+0x938/0xa1c
 [<c038b72f>] tcp_v4_do_rcv+0x8a/0x10e
 [<c03547ce>] __release_sock+0x3e/0x58
 [<c0354e42>] release_sock+0x6e/0x70
 [<c03994e0>] inet_wait_for_connect+0x7d/0xd1
---------------------------------------------------------
                                                                               
                                                         
I'm uncertain if it was really dead at this point, or if it
was just hanging waiting for the raid rebuild to finish. Anyway,
wasn't patient enough to find out.. and it felt dead.
                                                                               
                                                         
Afterwards I booted back to the RHEL 2.4.21-20 + 7.10.18 ips driver,
and the RAID was automatically rebuilt there. But, shouldn't this
driver work with 2.6? And, any reason the latest version isn't
included in the standard kernels?
                                                                               
                                                         

Steps to reproduce:

I expect the same problem to re-appear if I unplug and re-plug a disk in one of
the ServeRAID mirrored volumes.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
