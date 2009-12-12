From: Christian Kujau <lists@nerdbynature.de>
Subject: Badness at net/ipv4/inet_connection_sock.c:293
Date: Fri, 11 Dec 2009 23:43:10 -0800 (PST)
Message-ID: <alpine.DEB.2.01.0912112335440.2915@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757209AbZLLHnH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

today I upgraded from 2.6.32-rc7 to the latest -git (mainline) and after a 
few hours the messages below appeared in the log. Apparently "privoxy" was 
very busy handling connections, but the messages never appeared with 
earlier kernels. 

Full dmesg & .config is on:
http://nerdbynature.de/bits/2.6.33-git/inet_accept/

Thanks,
Christian.

 ------------[ cut here ]------------
 Badness at net/ipv4/inet_connection_sock.c:293
 NIP: c02a0914 LR: c02a0904 CTR: 00000000
 REGS: eeecbd30 TRAP: 0700   Not tainted  (2.6.32)
 MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002442  XER: 00000000
 TASK = eee9a820[1756] 'privoxy' THREAD: eeeca000
 GPR00: 00000001 eeecbde0 eee9a820 c03f7094 d4e86ba0 00000000 00001d40 00000000 
 GPR08: eeecbdf4 d4e86b40 00000000 c0d42000 00000000 10054804 bfedd9fc 10038614 
 GPR16: 100385f8 100385c8 00000000 1004c824 100385dc 1004c80c 1004c9d0 100385a4 
 GPR24: 1004c824 7fffffff fffffe04 eeecbe38 eeecbde8 7fffffff cb3b4840 eecc6520 
 NIP [c02a0914] inet_csk_accept+0x94/0x1f0
 LR [c02a0904] inet_csk_accept+0x84/0x1f0
 Call Trace:
 [eeecbde0] [c02a0904] inet_csk_accept+0x84/0x1f0 (unreliable)
 [eeecbe30] [c02c3794] inet_accept+0x40/0xb8
 [eeecbe50] [c0268448] sys_accept4+0xfc/0x1fc
 [eeecbf00] [c0268bd4] sys_socketcall+0x1d4/0x204
 [eeecbf40] [c0012dcc] ret_from_syscall+0x0/0x38
 --- Exception: c01 at 0xff393d4
     LR = 0xff393c0
 Instruction dump:
 0f000000 a13f00b4 7d645b78 3929ffff b13f00b4 816b0018 806b0008 4bdf0e41 
 881e0016 68000003 7c000034 5400d97e <0f000000> 7fe3fb78 4bfc948d 80010054 


 ------------[ cut here ]------------
 Badness at net/ipv4/af_inet.c:668
 NIP: c02c37b8 LR: c02c37a4 CTR: 00000000
 REGS: eeecbd80 TRAP: 0700   Tainted: G        W   (2.6.32)
 MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002442  XER: 00000000
 TASK = eee9a820[1756] 'privoxy' THREAD: eeeca000
 GPR00: 00000001 eeecbe30 eee9a820 cb3b4840 00000000 00000000 00001d40 00000000 
 GPR08: eeecbdf4 00000003 00000000 eeeca000 00000000 10054804 bfedd9fc 10038614 
 GPR16: 100385f8 100385c8 00000000 1004c824 100385dc 1004c80c 1004c9d0 100385a4 
 GPR24: 1004c824 ffffffff 00000010 bfedd9a8 bfedd9ac ef645580 e5a5dc60 cb3b4840 
 NIP [c02c37b8] inet_accept+0x64/0xb8
 LR [c02c37a4] inet_accept+0x50/0xb8
 Call Trace:
 [eeecbe30] [c02c37a4] inet_accept+0x50/0xb8 (unreliable)
 [eeecbe50] [c0268448] sys_accept4+0xfc/0x1fc
 [eeecbf00] [c0268bd4] sys_socketcall+0x1d4/0x204
 [eeecbf40] [c0012dcc] ret_from_syscall+0x0/0x38
 --- Exception: c01 at 0xff393d4
     LR = 0xff393c0
 Instruction dump:
 816b000c 7d6903a6 4e800421 7c7f1b79 4182005c 38800000 4bfa66b1 893f0016 
 38000182 7c004e30 68000001 540007fe <0f000000> 4bd722c9 381e0010 901f0044 



-- 
BOFH excuse #137:

User was distributing pornography on server; system seized by FBI.
