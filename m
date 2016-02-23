From: Sasha Levin <sasha.levin@oracle.com>
Subject: netfilter: warning at net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:275
 nf_nat_ipv4_fn
Date: Mon, 22 Feb 2016 19:55:58 -0500
Message-ID: <56CBAE1E.8030402@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	kadlec@blackhole.kfki.hu, netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I've hit the following warning while fuzzing with trinity inside a kvmtool guest
running the latest -next kernel:

[ 3196.268106] WARNING: CPU: 3 PID: 660 at net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:275 nf_nat_ipv4_fn+0x65d/0xab0()

[ 3196.268120] Modules linked in:

[ 3196.268142] CPU: 3 PID: 660 Comm: trinity-c95 Not tainted 4.5.0-rc4-next-20160219-sasha-00026-g7978205-dirty #2978

[ 3196.268173]  1ffff10017065e9b ffff8800b832f560 ffffffffa23d9a9d ffffffff00000003

[ 3196.268196]  fffffbfff5c2a630 0000000041b58ab3 ffffffffadb3a8f2 ffffffffa23d9905

[ 3196.268216]  ffffffffa059a760 ffff880371b25494 ffff8800b832f958 ffff8800b832f960

[ 3196.268222] Call Trace:

[ 3196.268273] dump_stack (lib/dump_stack.c:53)
[ 3196.268375] warn_slowpath_common (kernel/panic.c:483)
[ 3196.268417] warn_slowpath_null (kernel/panic.c:517)
[ 3196.268435] nf_nat_ipv4_fn (net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:275 (discriminator 1))
[ 3196.268543] nf_nat_ipv4_local_fn (net/ipv4/netfilter/nf_nat_l3proto_ipv4.c:429)
[ 3196.268573] iptable_nat_ipv4_local_fn (net/ipv4/netfilter/iptable_nat.c:65)
[ 3196.268596] nf_iterate (net/netfilter/core.c:275)
[ 3196.268622] nf_hook_slow (net/netfilter/core.c:306)
[ 3196.268701] raw_send_hdrinc (include/linux/netfilter.h:225 include/linux/netfilter.h:249 net/ipv4/raw.c:418)
[ 3196.268773] raw_sendmsg (net/ipv4/raw.c:640)
[ 3196.268869] inet_sendmsg (net/ipv4/af_inet.c:740)
[ 3196.268913] sock_sendmsg (net/socket.c:612 net/socket.c:621)
[ 3196.268927] SYSC_sendto (net/socket.c:1651)
[ 3196.269049] SyS_sendto (net/socket.c:1619)
[ 3196.269074] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:200)


Thanks,
Sasha
