From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: [RFC PATCH 0/2] PID-based network traffic monitoring
Date: Wed,  4 Apr 2012 10:16:15 +0100
Message-ID: <cover.1333466900.git.nuno.martins@caixamagica.pt>
Cc: Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: netdev <netdev@vger.kernel.org>, nuno.martins@caixamagica.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35689 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab2DDJQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:16:28 -0400
Received: by bkcik5 with SMTP id ik5so59839bkc.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:16:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 In this patchset we introduce the support for pid-based network monitoring, through a new BPF/LSF instruction, supported by KProbes to dynamically detect opening and closing connections.
 With these changes it is possible to pass a PID to tcpdump, and monitor the traffic on the network which belongs to a specific PID. More information can be found at the project page [1].

 * The first patch provides the infrastructure to registering custom BPF filter functions through setsockopt.
 * The second patch introduces a pid monitor that keeps track of the ongoing connections (src addr, dst addr, src port, dst, port and protocol), associated to a PID, passed from userspace as part of a custom BFP filter.

 For testing with tcpdump, a modified pcap library is required. The patch can be found at [2].
 This approach is still in early stages of development and under heavy testing. Any feedback or suggestions are appreciated.

 Thanks,

 Nuno Martins.

 [1] http://projects.caixamagica.pt/projects/pidmonitoring
 [2] http://projects.caixamagica.pt/projects/pidmonitoring/attachment/wiki/WikiStart/libpcap.patch

Nuno Martins (2):
  Multiple filter function support for BPF filters
  PID-based packet filtering support

 include/asm-generic/socket.h      |    4 +
 include/linux/filter.h            |    4 +-
 include/linux/socket.h            |   28 +++
 net/Kconfig                       |   15 ++
 net/Makefile                      |    1 +
 net/core/Makefile                 |    3 +-
 net/core/filter.c                 |    8 +-
 net/core/filter_function.c        |  133 +++++++++++
 net/core/sock.c                   |   23 +-
 net/pidmonitor/Makefile           |    3 +
 net/pidmonitor/db_monitor.c       |  389 ++++++++++++++++++++++++++++++
 net/pidmonitor/db_monitor.h       |   51 ++++
 net/pidmonitor/filter.c           |  476 +++++++++++++++++++++++++++++++++++++
 net/pidmonitor/filter.h           |   31 +++
 net/pidmonitor/pidmonitor.c       |  102 ++++++++
 net/pidmonitor/pidmonitor.h       |   63 +++++
 net/pidmonitor/proc_monitor.c     |  116 +++++++++
 net/pidmonitor/proc_monitor.h     |   23 ++
 net/pidmonitor/syscalls_monitor.c |  423 ++++++++++++++++++++++++++++++++
 net/pidmonitor/syscalls_monitor.h |   31 +++
 net/pidmonitor/task_monitor.c     |   77 ++++++
 net/pidmonitor/task_monitor.h     |   23 ++
 22 files changed, 2023 insertions(+), 4 deletions(-)
 create mode 100644 net/core/filter_function.c
 create mode 100644 net/pidmonitor/Makefile
 create mode 100644 net/pidmonitor/db_monitor.c
 create mode 100644 net/pidmonitor/db_monitor.h
 create mode 100644 net/pidmonitor/filter.c
 create mode 100644 net/pidmonitor/filter.h
 create mode 100644 net/pidmonitor/pidmonitor.c
 create mode 100644 net/pidmonitor/pidmonitor.h
 create mode 100644 net/pidmonitor/proc_monitor.c
 create mode 100644 net/pidmonitor/proc_monitor.h
 create mode 100644 net/pidmonitor/syscalls_monitor.c
 create mode 100644 net/pidmonitor/syscalls_monitor.h
 create mode 100644 net/pidmonitor/task_monitor.c
 create mode 100644 net/pidmonitor/task_monitor.h

-- 
1.7.10.rc3.11.gd8282
