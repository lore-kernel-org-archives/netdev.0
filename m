From: James Morris <jmorris@namei.org>
Subject: Re: [audit] Suppress runtime loading of audit module.
Date: Mon, 31 May 2010 10:27:43 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1005311026560.24571@tundra.namei.org>
References: <201005242057.EBJ00004.JOOFVHLFFQOStM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Audit-ML <linux-audit@redhat.com>,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201005242057.EBJ00004.JOOFVHLFFQOStM@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Might be best for the networking folk to look at this.



On Mon, 24 May 2010, Tetsuo Handa wrote:

> I noticed that request_module("net-pf-16-proto-9") is issued whenever 'Enter'
> key is pressed if CONFIG_AUDIT=n and console is /dev/tty0 . net-pf-16-proto-9
> is known as audit but CONFIG_AUDIT is "bool". Therefore, trying to load
> net-pf-16-proto-9 at runtime does not make sense.
> 
> Call trace obtained by inserting WARN_ON(protocol == 9);
> ------------[ cut here ]------------
> WARNING: at net/netlink/af_netlink.c:450 netlink_create+0x1cd/0x1e0()
> Hardware name: VMware Virtual Platform
> Modules linked in: mptspi mptscsih mptbase scsi_transport_spi ext3 jbd mbcache
> Pid: 1, comm: bash Not tainted 2.6.34 #10
> Call Trace:
>  [<c06227ad>] ? netlink_create+0x1cd/0x1e0
>  [<c043c9cc>] warn_slowpath_common+0x7c/0xa0
>  [<c06227ad>] ? netlink_create+0x1cd/0x1e0
>  [<c043ca05>] warn_slowpath_null+0x15/0x20
>  [<c06227ad>] netlink_create+0x1cd/0x1e0
>  [<c0600790>] ? __sock_create+0xe0/0x240
>  [<c06225e0>] ? netlink_create+0x0/0x1e0
>  [<c06007b8>] __sock_create+0x108/0x240
>  [<c060072e>] ? __sock_create+0x7e/0x240
>  [<c060095a>] sock_create+0x3a/0x50
>  [<c0600ae6>] sys_socket+0x36/0x60
>  [<c0601f69>] sys_socketcall+0x89/0x290
>  [<c0402b83>] ? sysenter_exit+0xf/0x18
>  [<c0524db4>] ? trace_hardirqs_on_thunk+0xc/0x10
>  [<c0402b50>] sysenter_do_call+0x12/0x36
> ---[ end trace 4da698b4c0bf1613 ]---
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/netlink/af_netlink.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.34.orig/net/netlink/af_netlink.c
> +++ linux-2.6.34/net/netlink/af_netlink.c
> @@ -446,7 +446,7 @@ static int netlink_create(struct net *ne
>  
>  	netlink_lock_table();
>  #ifdef CONFIG_MODULES
> -	if (!nl_table[protocol].registered) {
> +	if (!nl_table[protocol].registered && protocol != 9) {
>  		netlink_unlock_table();
>  		request_module("net-pf-%d-proto-%d", PF_NETLINK, protocol);
>  		netlink_lock_table();
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
