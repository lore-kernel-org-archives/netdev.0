From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 22:53:52 -0700
Message-ID: <1371534832.3252.206.camel@edumazet-glaptop>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
	 <1371490190.28418.6.camel@chenjun-workstation>
	 <1371464962.3252.181.camel@edumazet-glaptop>
	 <1371495133.28418.19.camel@chenjun-workstation>
	 <1371475281.3252.198.camel@edumazet-glaptop>
	 <1371549179.28418.28.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Jun Chen <jun.d.chen@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371549179.28418.28.camel@chenjun-workstation>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-06-18 at 05:52 -0400, Jun Chen wrote:
> > 
> There are many warning for tcp_recvmsg before this crash. I can't find
> other memory warning in the logs, but I'm not sure whether there are
> memory issues because of the length limitation of saved logs. I think
> this logs will give you more information.
> 
> <4>[ 7736.343742] ------------[ cut here ]------------
> 
> <4>[ 7736.343759] WARNING:
> at /data/buildbot/workdir/jb/kernel/net/ipv4/tcp.c:1496 tcp_recvmsg
> +0x3bf/0x910()
> 
> <4>[ 7736.343775] recvmsg bug: copied AB57C870 seq AB57CD95 rcvnxt
> AB57F19F fl 0
> 
> <4>[ 7736.343845] Call Trace:
> 
> <4>[ 7736.343865]  [<c1237032>] warn_slowpath_common+0x72/0xa0
> 
> <4>[ 7736.343888]  [<c18a955f>] ? tcp_recvmsg+0x3bf/0x910
> 
> <4>[ 7736.343902]  [<c18a955f>] ? tcp_recvmsg+0x3bf/0x910
> 
> <4>[ 7736.343922]  [<c1237103>] warn_slowpath_fmt+0x33/0x40
> 
> <4>[ 7736.343944]  [<c18a955f>] tcp_recvmsg+0x3bf/0x910
> 
> <4>[ 7736.343968]  [<c18c9bb5>] inet_recvmsg+0x85/0xa0
> 
> <4>[ 7736.343992]  [<c1852030>] sock_aio_read+0x140/0x160
> 
> <4>[ 7736.344016]  [<c126b221>] ? set_next_entity+0xc1/0xf0
> 
> <4>[ 7736.344039]  [<c130d627>] do_sync_read+0xb7/0xf0
> 
> <4>[ 7736.344064]  [<c130dc6c>] ? rw_verify_area+0x6c/0x120
> 
> <4>[ 7736.344077]  [<c1349aa8>] ? sys_epoll_wait+0x68/0x360
> 
> <4>[ 7736.344098]  [<c130e1e9>] vfs_read+0x149/0x160
> 
> <4>[ 7736.344120]  [<c130f518>] ? fget_light+0x58/0xd0
> 
> <4>[ 7736.344142]  [<c130e23d>] sys_read+0x3d/0x70
> 
> <4>[ 7736.344164]  [<c198c361>] syscall_call+0x7/0xb
> 
> <4>[ 7736.344187]  [<c1980000>] ? perf_cpu_notify+0x45/0x89
> 
> <4>[ 7736.344205] ---[ end trace b3c5b245ce7ff5b5 ]---
> 

Thats exactly the interesting stuff ;)

This was fixed, or should be fixed if still happening on more recent
kernels.

Basically, once we are in this state, there is nothing we can do to
prevent a crash.

Please try to reproduce the issue using 3.9 or David trees (net-next or
net )

Thanks
