From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6]: Fix oops in ipt action error path
Date: 09 Dec 2004 07:14:32 -0500
Message-ID: <1102594472.1048.50.camel@jzny.localdomain>
References: <41B7892E.1080706@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B7892E.1080706@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-08 at 18:07, Patrick McHardy wrote:
> This patch fixes an oops when the ipt action is used with a
> non-existant iptables target. It tries to log
> t->u.kernel.target->name, u.kernel.target is part of a union
> and as long as the target wasn't successfully loaded contains
> the name of the target, using it as a pointer results in a
> crash.
> 
> Oops captured in UML:
> 
> EIP: 0023:[<a01056e1>] CPU: 0 Not tainted ESP: 002b:a14b7514 EFLAGS: 
> 00010297
>     Not tainted
> EAX: 414d4e56 EBX: 0000000a ECX: 414d4e56 EDX: fffffffe
> ESI: a036acba EDI: 00000000 EBP: a036b09f DS: 002b ES: 002b
> Call Trace:
>  [<a004b96d>] notifier_call_chain+0x2d/0x50
>  [<a0101186>] bust_spinlocks+0x46/0x50
>  [<a0035cc1>] panic+0x71/0x120
>  [<a01056e1>] vsnprintf+0x331/0x4d0
>  [<a001ad6a>] segv+0x1fa/0x230
>  [<a01056e1>] vsnprintf+0x331/0x4d0
>  [<a01eaeb4>] sigemptyset+0x24/0x40
>  [<a0018c65>] change_signals+0x65/0x90
>  [<a001b1c0>] segv_handler+0xe0/0xf0
>  [<a01056e1>] vsnprintf+0x331/0x4d0
>  [<a001eccd>] sig_handler_common_tt+0x8d/0x120
>  [<a001b1f7>] sig_handler+0x17/0x20
>  [<a01ead88>] __restore+0x0/0x8
>  [<a01056e1>] vsnprintf+0x331/0x4d0
>  [<a01058ab>] vscnprintf+0x2b/0x40
>  [<a0036df2>] vprintk+0xb2/0x320
>  [<a0036d37>] printk+0x17/0x20
>  [<a0163653>] tcf_ipt_init+0x533/0x750
>  [<a015ea22>] tcf_action_init_1+0x92/0x1a0
>  [<a0069219>] kmem_cache_alloc+0x39/0x60
>  [<a01eaeb4>] sigemptyset+0x24/0x40
>  [<a015ebd7>] tcf_action_init+0xa7/0x140
> ...
> 
> Not very important right now since ipt support isn't merged in iproute
> yet, but still should be fixed for 2.6.10.
> 

I think it is valid to apply now; 
Thanks Patrick. If you have more cleanups on ipt, please shoot them in
as well. 
I am going to resend the ipt iproute2 patch to Stephen now that he is
awake.
 
cheers,
jamal
