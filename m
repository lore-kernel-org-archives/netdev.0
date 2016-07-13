From: Mason <slash.tmp@free.fr>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Wed, 13 Jul 2016 14:11:44 +0200
Message-ID: <57863000.4030304@free.fr>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com> <5784BE36.8060200@free.fr>
 <1468333513.30694.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <578500FB.6090503@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>, netdev <netdev@vger.kernel.org>,
 Florian Fainelli <f.fainelli@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <578500FB.6090503@free.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 12/07/2016 16:38, Mason wrote:

> With Eric's patch applied, I get this warning at boot:
> 
> [    4.668309] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
> [    4.688609] Sending DHCP requests ., OK
> [    4.711935] IP-Config: Got DHCP answer from 172.27.200.1, my address is 172.27.64.49
> [    4.719956] IP-Config: Complete:
> [    4.723221]      device=eth0, hwaddr=00:16:e8:02:08:42, ipaddr=172.27.64.49, mask=255.255.192.0, gw=172.27.64.1
> [    4.733376]      host=toto5, domain=france.foo.com sac.foo.com asic.foo.com soft.sde, nis-domain=france.foo.com
> [    4.745279]      bootserver=172.27.64.1, rootserver=172.27.64.1, rootpath=/export/roots/titi/6_2_0_8756,v3     nameserver0=172.27.0.17
> [    4.759725] ------------[ cut here ]------------
> [    4.764426] WARNING: CPU: 0 PID: 877 at net/core/sock.c:1468 sk_destruct+0x74/0x78
> [    4.772056] Modules linked in:
> [    4.775133] CPU: 0 PID: 877 Comm: kworker/0:1H Not tainted 4.7.0-rc6-00010-gd07031bdc433-dirty #6
> [    4.784050] Hardware name: Sigma Tango DT
> [    4.788084] Workqueue: rpciod rpc_async_schedule
> [    4.792725] Backtrace: 
> [    4.795196] [<c010b974>] (dump_backtrace) from [<c010bb70>] (show_stack+0x18/0x1c)
> [    4.802802]  r7:60000013 r6:c080ea84 r5:00000000 r4:c080ea84
> [    4.808513] [<c010bb58>] (show_stack) from [<c02e9fe4>] (dump_stack+0x80/0x94)
> [    4.815781] [<c02e9f64>] (dump_stack) from [<c011bfc8>] (__warn+0xec/0x104)
> [    4.822776]  r7:00000009 r6:c05e4d04 r5:00000000 r4:00000000
> [    4.828482] [<c011bedc>] (__warn) from [<c011c098>] (warn_slowpath_null+0x28/0x30)
> [    4.836089]  r9:00000000 r8:df5edb58 r7:df711364 r6:df006c80 r5:df5edb58 r4:df5eda40
> [    4.843898] [<c011c070>] (warn_slowpath_null) from [<c03fbd54>] (sk_destruct+0x74/0x78)
> [    4.851945] [<c03fbce0>] (sk_destruct) from [<c03fbda8>] (__sk_free+0x50/0xbc)
> [    4.859203]  r5:df5edb58 r4:df5eda40
> [    4.862802] [<c03fbd58>] (__sk_free) from [<c03fbe50>] (sk_free+0x3c/0x40)
> [    4.869710]  r5:df5edb58 r4:df5eda40
> [    4.873310] [<c03fbe14>] (sk_free) from [<c03fbf80>] (sk_common_release+0xe8/0xf4)
> [    4.880924] [<c03fbe98>] (sk_common_release) from [<c0467e50>] (udp_lib_close+0x10/0x14)
> [    4.889054]  r5:df006c80 r4:df5eda40
> [    4.892657] [<c0467e40>] (udp_lib_close) from [<c0473dbc>] (inet_release+0x4c/0x78)
> [    4.900360] [<c0473d70>] (inet_release) from [<c03f605c>] (sock_release+0x28/0xa8)
> [    4.907967]  r5:00000000 r4:df006c80
> [    4.911575] [<c03f6034>] (sock_release) from [<c049a7f4>] (xs_reset_transport+0xac/0xbc)
> [    4.919706]  r5:df5eda40 r4:df711000
> [    4.923306] [<c049a748>] (xs_reset_transport) from [<c049a850>] (xs_destroy+0x24/0x54)
> [    4.931262]  r9:00000000 r8:c049c614 r7:df7c3218 r6:df711000 r5:00000000 r4:df711000
> [    4.939070] [<c049a82c>] (xs_destroy) from [<c0497c18>] (xprt_destroy+0x88/0x8c)
> [    4.946502]  r5:df711218 r4:df711000
> [    4.950102] [<c0497b90>] (xprt_destroy) from [<c0497c5c>] (xprt_put+0x40/0x44)
> [    4.957358]  r5:df7c3200 r4:df613d00
> [    4.960959] [<c0497c1c>] (xprt_put) from [<c04968e4>] (rpc_task_release_client+0x7c/0x80)
> [    4.969181] [<c0496868>] (rpc_task_release_client) from [<c049c3ac>] (rpc_release_resources_task+0x34/0x38)
> [    4.978971]  r7:c049c298 r6:00000001 r5:00000000 r4:df613d00
> [    4.984674] [<c049c378>] (rpc_release_resources_task) from [<c049cdc8>] (__rpc_execute+0xb0/0x2a8)
> [    4.993678]  r5:00000000 r4:df613d00
> [    4.997277] [<c049cd18>] (__rpc_execute) from [<c049cfd4>] (rpc_async_schedule+0x14/0x18)
> [    5.005496]  r10:df683500 r9:00000000 r8:dfbe4700 r7:00000000 r6:dfbdcc80 r5:df683500
> [    5.013383]  r4:df613d24
> [    5.015935] [<c049cfc0>] (rpc_async_schedule) from [<c0132640>] (process_one_work+0x128/0x3fc)
> [    5.024595] [<c0132518>] (process_one_work) from [<c013296c>] (worker_thread+0x58/0x574)
> [    5.032726]  r10:df683500 r9:df6d4000 r8:dfbdcc98 r7:c0802100 r6:00000008 r5:df683518
> [    5.040614]  r4:dfbdcc80
> [    5.043162] [<c0132914>] (worker_thread) from [<c0138470>] (kthread+0xe4/0xfc)
> [    5.050419]  r10:00000000 r9:00000000 r8:00000000 r7:c0132914 r6:df683500 r5:df6cc600
> [    5.058309]  r4:00000000
> [    5.060858] [<c013838c>] (kthread) from [<c0107c18>] (ret_from_fork+0x14/0x3c)
> [    5.068116]  r7:00000000 r6:00000000 r5:c013838c r4:df6cc600
> [    5.073846] ---[ end trace 05b24e2dedd2f2a0 ]---
> [    5.082009] VFS: Mounted root (nfs filesystem) readonly on device 0:11.
> [    5.090328] Freeing unused kernel memory: 1024K (c0700000 - c0800000)
> [    5.452552] random: udevd urandom read with 68 bits of entropy available

AFAICT, I get the same call stack for every boot.

Is this an unexpected call sequence?

Are there other tests I can run?

Regards.
