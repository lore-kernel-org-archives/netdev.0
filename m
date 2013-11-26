From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Date: Tue, 26 Nov 2013 14:11:57 -0500
Message-ID: <5294F27D.4000108@oracle.com>
References: <522B25B5.6000808@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <522B25B5.6000808@oracle.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping? I still see this warning.

On 09/07/2013 09:10 AM, Sasha Levin wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest, running latest -next kernel, I've
> stumbled on the following:
>
> [  418.311956] ------------[ cut here ]------------
> [  418.312449] WARNING: CPU: 6 PID: 4178 at lib/debugobjects.c:260 debug_print_object+0x8d/0xb0()
> [  418.313243] ODEBUG: free active (active state 0) object type: timer_list hint:
> delayed_work_timer_fn+0x0/0x20
> [  418.314038] Modules linked in:
> [  418.314038] CPU: 6 PID: 4178 Comm: kworker/u16:2 Tainted: G        W 3.11.0-next-20130906-sasha
> #3984
> [  418.314038] Workqueue: netns cleanup_net
> [  418.314038]  0000000000000104 ffff880410371a58 ffffffff841b7815 0000000000000104
> [  418.314038]  ffff880410371aa8 ffff880410371a98 ffffffff8112540c ffff880410371a78
> [  418.314038]  ffffffff853ea0ab ffff8800bdc68b80 ffffffff85a65c00 ffffffff87676658
> [  418.314038] Call Trace:
> [  418.314038]  [<ffffffff841b7815>] dump_stack+0x52/0x87
> [  418.320315]  [<ffffffff8112540c>] warn_slowpath_common+0x8c/0xc0
> [  418.321040]  [<ffffffff811254f6>] warn_slowpath_fmt+0x46/0x50
> [  418.321101]  [<ffffffff81a60ded>] debug_print_object+0x8d/0xb0
> [  418.321101]  [<ffffffff811444e0>] ? __queue_work+0x390/0x390
> [  418.321101]  [<ffffffff81a61605>] __debug_check_no_obj_freed+0xa5/0x220
> [  418.321101]  [<ffffffff81249e76>] ? kmem_cache_destroy+0x86/0xe0
> [  418.321101]  [<ffffffff81a61795>] debug_check_no_obj_freed+0x15/0x20
> [  418.321101]  [<ffffffff812874d7>] kmem_cache_free+0x197/0x340
> [  418.321101]  [<ffffffff81249e76>] kmem_cache_destroy+0x86/0xe0
> [  418.321101]  [<ffffffff83d5d681>] nf_conntrack_cleanup_net_list+0x131/0x170
> [  418.321101]  [<ffffffff83d5ec5d>] nf_conntrack_pernet_exit+0x5d/0x70
> [  418.321101]  [<ffffffff83cda1ce>] ops_exit_list+0x5e/0x70
> [  418.321101]  [<ffffffff83cda80b>] cleanup_net+0xfb/0x1c0
> [  418.321101]  [<ffffffff81145c28>] process_one_work+0x338/0x550
> [  418.321101]  [<ffffffff81145b50>] ? process_one_work+0x260/0x550
> [  418.321883]  [<ffffffff81147605>] worker_thread+0x215/0x350
> [  418.321883]  [<ffffffff811473f0>] ? manage_workers+0x180/0x180
> [  418.321883]  [<ffffffff81150887>] kthread+0xe7/0xf0
> [  418.321883]  [<ffffffff811507a0>] ? __init_kthread_worker+0x70/0x70
> [  418.321883]  [<ffffffff841c7a2c>] ret_from_fork+0x7c/0xb0
> [  418.321883]  [<ffffffff811507a0>] ? __init_kthread_worker+0x70/0x70
> [  418.321883] ---[ end trace c974221542b61d0d ]---
>
>
> Thanks,
> Sasha

