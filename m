From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix NULL pointer dereference in endpoint
 destruction
Date: Wed, 05 Jun 2013 15:42:54 +0200
Message-ID: <51AF405E.9040801@redhat.com>
References: <1370426303-2069-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752992Ab3FENm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 09:42:58 -0400
In-Reply-To: <1370426303-2069-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2013 11:58 AM, Daniel Borkmann wrote:
> While stress testing sctp sockets, I hit the following panic:
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> IP: [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
> PGD 7cead067 PUD 7ce76067 PMD 0
> Oops: 0000 [#1] SMP
> Modules linked in: sctp(F) libcrc32c(F) [...]
> CPU: 7 PID: 2950 Comm: acc Tainted: GF            3.10.0-rc2+ #1
> Hardware name: Dell Inc. PowerEdge T410/0H19HD, BIOS 1.6.3 02/01/2011
> task: ffff88007ce0e0c0 ti: ffff88007b568000 task.ti: ffff88007b568000
> RIP: 0010:[<ffffffffa0490c4e>]  [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
> RSP: 0018:ffff88007b569e08  EFLAGS: 00010292
> RAX: 0000000000000000 RBX: ffff88007db78a00 RCX: dead000000200200
> RDX: ffffffffa049fdb0 RSI: ffff8800379baf38 RDI: 0000000000000000
> RBP: ffff88007b569e18 R08: ffff88007c230da0 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: ffff880077990d00 R14: 0000000000000084 R15: ffff88007db78a00
> FS:  00007fc18ab61700(0000) GS:ffff88007fc60000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000020 CR3: 000000007cf9d000 CR4: 00000000000007e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Stack:
>   ffff88007b569e38 ffff88007db78a00 ffff88007b569e38 ffffffffa049fded
>   ffffffff81abf0c0 ffff88007db78a00 ffff88007b569e58 ffffffff8145b60e
>   0000000000000000 0000000000000000 ffff88007b569eb8 ffffffff814df36e
> Call Trace:
>   [<ffffffffa049fded>] sctp_destroy_sock+0x3d/0x80 [sctp]
>   [<ffffffff8145b60e>] sk_common_release+0x1e/0xf0
>   [<ffffffff814df36e>] inet_create+0x2ae/0x350
>   [<ffffffff81455a6f>] __sock_create+0x11f/0x240
>   [<ffffffff81455bf0>] sock_create+0x30/0x40
>   [<ffffffff8145696c>] SyS_socket+0x4c/0xc0
>   [<ffffffff815403be>] ? do_page_fault+0xe/0x10
>   [<ffffffff8153cb32>] ? page_fault+0x22/0x30
>   [<ffffffff81544e02>] system_call_fastpath+0x16/0x1b
> Code: 0c c9 c3 66 2e 0f 1f 84 00 00 00 00 00 e8 fb fe ff ff c9 c3 66 0f
>        1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 <48>
>        8b 47 20 48 89 fb c6 47 1c 01 c6 40 12 07 e8 9e 68 01 00 48
> RIP  [<ffffffffa0490c4e>] sctp_endpoint_free+0xe/0x40 [sctp]
>   RSP <ffff88007b569e08>
> CR2: 0000000000000020
> ---[ end trace e0d71ec1108c1dd9 ]---

Please hold on with this one. It seemed, that the two tests with this patch
applied did not trigger this BUG ``by accident''. I'm still seeing it, digging
further on the cause and will send a v2 when eventually identified.
