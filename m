From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: That's pretty much it for 3.5.0
Date: Wed, 18 Jul 2012 19:55:39 +0200
Message-ID: <1342634139.2626.3281.camel@edumazet-glaptop>
References: <5005D008.6060103@intel.com>
	 <20120717.140241.1599386555723262095.davem@davemloft.net>
	 <5005E390.7020706@intel.com>
	 <20120717.151832.1306978935355646723.davem@davemloft.net>
	 <5005F4F9.6010208@intel.com>
	 <20120718130430.GE25563@hmsreliant.think-freely.org>
	 <205259E8-A99F-4573-96C9-7A394235B338@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"<h@hmsreliant.think-freely.org>" <h@hmsreliant.think-freely.org>,
	David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
	"<netfilter-devel@vger.kernel.org>" <netfilter-devel@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <205259E8-A99F-4573-96C9-7A394235B338@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-18 at 17:36 +0000, Rustad, Mark D wrote:
> On Jul 18, 2012, at 6:04 AM, Neil Horman wrote:
> 
> > John, can you post the backtrace you got for this?  I replied to the patch that
> > you posted for this fix.  the cgroup subsystem has an early_init flag thats
> > supposed to prevent the initialization of cgroups that don't need initialization
> > until later (like via module_init() calls).
> 
> Here is the backtrace that I get and below a patch that fixes it:
> 
> [    0.010958] Initializing cgroup subsys net_prio
> [    0.011040] BUG: unable to handle kernel NULL pointer dereference at 0000000000000828
> [    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
> [    0.011998] PGD 0 
> [    0.011998] Oops: 0000 [#1] SMP 
> [    0.011998] CPU 0 
> [    0.011998] Modules linked in:
> [    0.011998] 
> [    0.011998] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc7-mdrlinux+ #10 Bochs Bochs
> [    0.011998] RIP: 0010:[<ffffffff814202c8>]  [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
> [    0.011998] RSP: 0000:ffffffff81a01e68  EFLAGS: 00010246
> [    0.011998] RAX: 0000000000000000 RBX: fffffffffffffed0 RCX: 0000000000000000
> [    0.011998] RDX: 0000000000000006 RSI: 2222222222222222 RDI: 2222222222222222
> [    0.011998] RBP: ffffffff81a01e88 R08: 2222222222222222 R09: 2222222222222222
> [    0.011998] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000001
> [    0.011998] R13: 0000000000000000 R14: ffff88007ff608c0 R15: 00000000000143d0
> [    0.011998] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> [    0.011998] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [    0.011998] CR2: 0000000000000828 CR3: 0000000001a0b000 CR4: 00000000000006b0
> [    0.011998] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    0.011998] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [    0.011998] Process swapper/0 (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a13420)
> [    0.011998] Stack:
> [    0.011998]  ffffffff81a88020 0000000000000000 ffff88007d3a38f0 fffffffffffffff4
> [    0.011998]  ffffffff81a01ec8 ffffffff814203cd ffff88007ff608c0 ffffffff817d8e9a
> [    0.011998]  ffffffff81a88cd8 ffffffff81a88020 ffffffff81a88020 ffffffff81b010a0
> [    0.011998] Call Trace:
> [    0.011998]  [<ffffffff814203cd>] cgrp_create+0x8d/0xc0
> [    0.011998]  [<ffffffff81ade14a>] cgroup_init_subsys+0x80/0x126
> [    0.011998]  [<ffffffff81ade380>] cgroup_init+0x36/0x117
> [    0.011998]  [<ffffffff81acab71>] start_kernel+0x32e/0x34f
> [    0.011998]  [<ffffffff81aca6d5>] ? repair_env_string+0x5a/0x5a
> [    0.011998]  [<ffffffff81aca346>] x86_64_start_reservations+0x101/0x105
> [    0.011998]  [<ffffffff81aca120>] ? early_idt_handlers+0x120/0x120
> [    0.011998]  [<ffffffff81aca417>] x86_64_start_kernel+0xcd/0xdc
> [    0.011998] Code: 0f 1f 00 48 8b 83 30 01 00 00 48 8d 98 d0 fe ff ff 48 3d a8 e8 52 82 74 3a e8 25 db c3 ff 85 c0 74 09 80 3d bb 3d 68 00 00 74 40 <48> 8b 83 58 09 00 00 48 85 c0 74 cc 44 3b 60 10 76 c6 44 89 e6 
> [    0.011998] RIP  [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
> [    0.011998]  RSP <ffffffff81a01e68>
> [    0.011998] CR2: 0000000000000828
> [    0.012009] ---[ end trace a7919e7f17c0a725 ]---
> [    0.012601] Kernel panic - not syncing: Attempted to kill the idle task!
> 
> The following change simply statically initializes init_net.dev_base_head. I copied and pasted it into the email, so this rendering may not work, but I can send it if this approach looks reasonable. I have verified that it resolves the issue above.
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0f28a9e..db1ba61 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6283,8 +6283,6 @@ static struct hlist_head *netdev_create_hash(void)
>  /* Initialize per network namespace state */
>  static int __net_init netdev_init(struct net *net)
>  {
> -       INIT_LIST_HEAD(&net->dev_base_head);
> -

	if (net != &init_net)
		INIT_LIST_HEAD(&net->dev_base_head);

>         net->dev_name_head = netdev_create_hash();
>         if (net->dev_name_head == NULL)
>                 goto err_name;
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index dddbacb..42f1e1c 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -27,7 +27,9 @@ static DEFINE_MUTEX(net_mutex);
>  LIST_HEAD(net_namespace_list);
>  EXPORT_SYMBOL_GPL(net_namespace_list);
>  
> -struct net init_net;
> +struct net init_net = {
> +       .dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
> +};
>  EXPORT_SYMBOL(init_net);
>  
>  #define INITIAL_NET_GEN_PTRS   13 /* +1 for len +2 for rcu_head */
> 


