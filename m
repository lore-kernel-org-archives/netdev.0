From: Cong Wang <amwang@redhat.com>
Subject: A kernel warning at net/netlink/af_netlink.c:797
Date: Sun, 21 Apr 2013 17:21:46 +0800
Message-ID: <1366536106.23100.10.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964Ab3DUJWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 05:22:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again, Patrick,

I also noticed the following kernel warning today, which is likely
caused by your netlink mmap patches, although I haven't tried to
revert/skip them to confirm.

I have CONFIG_NETLINK_MMAP=y in my .config. And line 797 is:

 797         WARN_ON(atomic_read(&sk->sk_rmem_alloc));  <=== THIS
 798         WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 799         WARN_ON(nlk_sk(sk)->groups);



[   38.900152] ------------[ cut here ]------------
[   38.901996] WARNING: at net/netlink/af_netlink.c:797
netlink_sock_destruct+0xd8/0x115()
[   38.905460] Hardware name: Bochs
[   38.906396] Pid: 123, comm: kworker/u:1 Tainted: G      D W
3.9.0-rc5+ #847
[   38.908575] Call Trace:
[   38.909300]  [<ffffffff810503dd>] warn_slowpath_common+0x7e/0x98
[   38.910979]  [<ffffffff810504c2>] warn_slowpath_null+0x1a/0x1c
[   38.916594]  [<ffffffff817c3497>] netlink_sock_destruct+0xd8/0x115
[   38.918285]  [<ffffffff8175e1ae>] __sk_free+0x1d/0x178
[   38.919812]  [<ffffffff8175f4e1>] sk_free+0x26/0x2a
[   38.921340]  [<ffffffff8175f503>] sock_put+0x1e/0x22
[   38.922701]  [<ffffffff8175f6a4>] sk_release_kernel+0x4e/0x52
[   38.924304]  [<ffffffff817c4f5a>] netlink_kernel_release+0xe/0x10
[   38.926092]  [<ffffffff8177c209>] rtnetlink_net_exit+0x1b/0x2b
[   38.930048]  [<ffffffff817698bc>] ops_exit_list+0x27/0x50
[   38.931582]  [<ffffffff8176a127>] cleanup_net+0xe7/0x175
[   38.933486]  [<ffffffff8106a4f9>] process_one_work+0x251/0x415
[   38.935303]  [<ffffffff8106a42c>] ? process_one_work+0x184/0x415
[   38.936964]  [<ffffffff8106b175>] worker_thread+0x13e/0x1d2
[   38.939839]  [<ffffffff8106b037>] ? manage_workers+0xf1/0xf1
[   38.941488]  [<ffffffff81073145>] kthread+0xb1/0xb9
[   38.943141]  [<ffffffff8107e497>] ? finish_task_switch+0x3d/0xc9
[   38.944851]  [<ffffffff81073094>] ? freezing+0x17/0x17
[   38.946334]  [<ffffffff81981bac>] ret_from_fork+0x7c/0xb0
[   38.947867]  [<ffffffff81073094>] ? freezing+0x17/0x17
[   38.949313] ---[ end trace dcfd26e5be103cba ]---

Thanks.
