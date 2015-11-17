From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Asterisk deadlocks since Kernel 4.1
Date: Tue, 17 Nov 2015 15:46:21 +0100
Message-ID: <564B3DBD.60500@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:23691 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbKQOqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 09:46:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

since Upgrading our Asterisk System from Kernel 3.18.17 to 4.1.13 it
deadlocks every few hours (kill -9 is the only thing working). Booting
with 3.18 again let it run smooth again.

An strace shows asterisk is looping like this:

[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0
[pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
[pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
2, 1000) = 1 ([{fd=8, revents=POLLIN}])
[pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
it_value={0, 140592906050976}}) = 0

fd 8 is:

lrwx------ 1 root root 64 Nov 17 15:27 /proc/6025/fd/8 ->
anon_inode:[timerfd]


# cat /proc/6025/stack
[<ffffffff941d60e9>] poll_schedule_timeout+0x49/0x70
[<ffffffff941d76c7>] do_sys_poll+0x3d7/0x590
[<ffffffff941d78bc>] do_restart_poll+0x3c/0x70
[<ffffffff9408e7ff>] sys_restart_syscall+0x1f/0x30
[<ffffffff9463f1ee>] system_call_fastpath+0x12/0x71
[<ffffffffffffffff>] 0xffffffffffffffff

Any ideas how to debug this?

Greets,
Stefan
