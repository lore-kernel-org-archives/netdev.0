From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Help regarding kernel hang issue
Date: Sat, 2 Mar 2013 10:08:35 +0530
Message-ID: <CADAe=+KRV4zaW2z0mWFt5KNHN1_30KN=X7ip5kOZpsOkTn9-rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:41097 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab3CBEjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 23:39:07 -0500
Received: by mail-ee0-f47.google.com with SMTP id e52so2787407eek.34
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 20:39:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Any pointers or help would be of great help for the below issue.

I am trying to run a kernel module in 3.6 kernel and finding a hang
issue ideally seems to be because of locks. I could see the trace as
shown below. Since it is a hang I could see some more traces on screen
but cannot capture them fully.

When I tried KGDB .. I dont see any hang in my target machine other
than the same log in dmesg. Why doesn't kernel hang reproducible with
KGDB ??

[  514.299185] ------------[ cut here ]------------
[  514.299999] WARNING: at kernel/lockdep.c:2966 lockdep_init_map+0x16a/0x420()
[  514.307653] Hardware name: VirtualBox
[  514.307735] Modules linked in: l2_module ppdev joydev microcode
pcspkr parport_pc i2c_piix4 e1000 parport i2c_core uinput
[  514.308001] Pid: 911, comm: pm Not tainted 3.6.11-ZebOS #3
[  514.310001] Call Trace:
[  514.311000]  [<c043c812>] warn_slowpath_common+0x72/0xa0
[  514.312995]  [<c0494b4a>] ? lockdep_init_map+0x16a/0x420
[  514.317999]  [<c0494b4a>] ? lockdep_init_map+0x16a/0x420
[  514.320622]  [<c043c862>] warn_slowpath_null+0x22/0x30
[  514.322959]  [<c0494b4a>] lockdep_init_map+0x16a/0x420
[  514.324957]  [<c08706b5>] sk_alloc+0x95/0xf0
[  514.326986]  [<e09ec430>] garp_create+0x47/0xea [l2_module]
[  514.329282]  [<c086bb70>] ? __sock_create+0x140/0x250
[  514.330932]  [<c086bac6>] ? __sock_create+0x96/0x250
[  514.333271]  [<c0984580>] ? spurious_fault+0x9b/0x9b
[  514.335002]  [<c086bcfd>] sock_create+0x3d/0x50
[  514.336986]  [<c086c2e2>] sys_socket+0x32/0x80
[  514.372351]  [<c086d480>] sys_socketcall+0x70/0x2d0
[  514.408357]  [<c06882a1>] ? copy_to_user+0x41/0x60
[  514.444340]  [<c09816d0>] syscall_call+0x7/0xb
[  514.479187] ---[ end trace 13a03f62973de4ee ]---

Regards,
Ajith
