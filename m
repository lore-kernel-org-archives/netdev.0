From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 9 Jul 2017 11:49:47 -0700
Message-ID: <CA+55aFzocFTX5JR9oG_5uKw-fT6OJUMkD71sypbec7JP=_qwpg@mail.gmail.com>
References: <20170708.113644.1272962770645338865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33714 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbdGISts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 14:49:48 -0400
In-Reply-To: <20170708.113644.1272962770645338865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 8, 2017 at 3:36 AM, David Miller <davem@davemloft.net> wrote:
>
> 8) Fix socket leak on accept() in RDS, from Sowmini Varadhan.  Also
>    add a WARN_ON() to sock_graft() so other protocol stacks don't trip
>    over this as well.

Hmm. This one triggers for me on both my desktop and laptop at bootup.
Bog-standard machines, running F25 and F24 respectively.

The warning doesn't seem particularly useful, although maybe that
"alg_accept()" gives people who know this code enough of a clue.

                       Linus

------------[ cut here ]------------
WARNING: CPU: 1 PID: 492 at ./include/net/sock.h:1700 af_alg_accept+0x1bf/0x1f0
CPU: 1 PID: 492 Comm: systemd-cryptse Not tainted 4.12.0-09010-g2b976203417c #1
Hardware name: System manufacturer System Product Name/Z170-K, BIOS
1803 05/06/2016
RIP: 0010:af_alg_accept+0x1bf/0x1f0
Call Trace:
 alg_accept+0x15/0x20
 SYSC_accept4+0x105/0x210
 ? getnstimeofday64+0xe/0x20
 ? __audit_syscall_entry+0xb1/0xf0
 ? syscall_trace_enter+0x1bd/0x2d0
 ? __audit_syscall_exit+0x1a5/0x2a0
 SyS_accept+0x10/0x20
 do_syscall_64+0x61/0x140
 entry_SYSCALL64_slow_path+0x25/0x25
---[ end trace a35e5baea85df269 ]---
