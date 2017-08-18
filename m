From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Fix oops when discarding a preallocated
 service call
Date: Fri, 18 Aug 2017 16:24:30 -0700 (PDT)
Message-ID: <20170818.162430.2009083209775876103.davem@davemloft.net>
References: <150301198243.6876.2468782049364321310.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        stable@vger.kernel.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150301198243.6876.2468782049364321310.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 18 Aug 2017 00:19:42 +0100

> rxrpc_service_prealloc_one() doesn't set the socket pointer on any new call
> it preallocates, but does add it to the rxrpc net namespace call list.
> This, however, causes rxrpc_put_call() to oops when the call is discarded
> when the socket is closed.  rxrpc_put_call() needs the socket to be able to
> reach the namespace so that it can use a lock held therein.
> 
> Fix this by setting a call's socket pointer immediately before discarding
> it.
> 
> This can be triggered by unloading the kafs module, resulting in an oops
> like the following:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
> IP: rxrpc_put_call+0x1e2/0x32d
> PGD 0
> P4D 0
> Oops: 0000 [#1] SMP
> Modules linked in: kafs(E-)
> CPU: 3 PID: 3037 Comm: rmmod Tainted: G            E   4.12.0-fscache+ #213
> Hardware name: ASUS All Series/H97-PLUS, BIOS 2306 10/09/2014
> task: ffff8803fc92e2c0 task.stack: ffff8803fef74000
> RIP: 0010:rxrpc_put_call+0x1e2/0x32d
> RSP: 0018:ffff8803fef77e08 EFLAGS: 00010282
> RAX: 0000000000000000 RBX: ffff8803fab99ac0 RCX: 000000000000000f
> RDX: ffffffff81c50a40 RSI: 000000000000000c RDI: ffff8803fc92ea88
> RBP: ffff8803fef77e30 R08: ffff8803fc87b941 R09: ffffffff82946d20
> R10: ffff8803fef77d10 R11: 00000000000076fc R12: 0000000000000005
> R13: ffff8803fab99c20 R14: 0000000000000001 R15: ffffffff816c6aee
> FS:  00007f915a059700(0000) GS:ffff88041fb80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000030 CR3: 00000003fef39000 CR4: 00000000001406e0
> Call Trace:
>  rxrpc_discard_prealloc+0x325/0x341
>  rxrpc_listen+0xf9/0x146
>  kernel_listen+0xb/0xd
>  afs_close_socket+0x3e/0x173 [kafs]
>  afs_exit+0x1f/0x57 [kafs]
>  SyS_delete_module+0x10f/0x19a
>  do_syscall_64+0x8a/0x149
>  entry_SYSCALL64_slow_path+0x25/0x25
> 
> Fixes: 2baec2c3f854 ("rxrpc: Support network namespacing")
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, but...

> cc: stable@vger.kernel.org

This is inappropriate for two reasons.

The code in question is new in 4.13-rcX and therefore does not need a
stable backport.

Secondly, I handle all networking stable submissions explicitly, so
please just tell me that a change should go to -stable and I will
queue it up for you, thanks.
