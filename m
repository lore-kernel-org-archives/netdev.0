From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 09:00:22 -0700
Message-ID: <1401292822.3645.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	 <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACP96tRBiANHxXSFZ_w7eKwO_zWk_AZv-7CDJFLSP6+bZJLZ5g@mail.gmail.com>
	 <1401284699.5367.268.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1401288533.5367.271.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>,
	Jiri Pirko <jiri@resnulli.us>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:52494 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbaE1QAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 12:00:25 -0400
Received: by mail-ie0-f177.google.com with SMTP id y20so10024826ier.8
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 09:00:25 -0700 (PDT)
In-Reply-To: <1401288533.5367.271.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-28 at 07:48 -0700, Eric Dumazet wrote:


> for i in `seq 0 255`; do for j in `seq 0 255`; do echo "addr add 127.2.$i.$j/8 dev lo"; done; done >batch
> ip -b batch

BTW, do not try after previous additions following command 

ip addr del 127.0.0.1/8 dev lo

It triggers a softlockup :(

[ 1074.543962] BUG: soft lockup - CPU#11 stuck for 11s! [ip:10729]
[ 1074.549908] task: ffff8808afa15580 ti: ffff8808afb18000 task.ti: ffff8808afb18000
[ 1074.549909] RIP: 0010:[<ffffffff8152d991>]  [<ffffffff8152d991>] fib_del_ifaddr+0x161/0x490
[ 1074.549915] RSP: 0018:ffff8808afb19878  EFLAGS: 00000202
[ 1074.549916] RAX: ffff880891705640 RBX: 0000000000000000 RCX: 0000000000000001
[ 1074.549917] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 000000000000000e
[ 1074.549918] RBP: ffff8808afb198d8 R08: 0000000000000000 R09: 000000000100007f
[ 1074.549919] R10: ffff880891705640 R11: 000000000000007f R12: ffff88089a417ec0
[ 1074.549920] R13: ffff88089a417ec0 R14: 0000000000000286 R15: 000000007f02b9e9
[ 1074.549921] FS:  00007f92f64d66d0(0000) GS:ffff88107fc60000(0000) knlGS:0000000000000000
[ 1074.549922] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1074.549923] CR2: 00000000022f9008 CR3: 0000000891b41000 CR4: 00000000000427e0
[ 1074.549924] Stack:
[ 1074.549925]  ffff8801143f7d40 0000000000000000 ffff88088f0c3000 00000000812f3f40
[ 1074.549934]  ffff88010fdf4a00 ffffff7f00000001 000000d000000000 ffff88088f0c3000
[ 1074.549944]  ffffffff81c73a00 0000000000000002 ffff8801143f7d40 0000000000000000
[ 1074.549953] Call Trace:
[ 1074.549958]  [<ffffffff8152dd46>] fib_inetaddr_event+0x86/0xe0
[ 1074.549965]  [<ffffffff8156699d>] notifier_call_chain+0x4d/0x70
[ 1074.549972]  [<ffffffff81078c08>] __blocking_notifier_call_chain+0x58/0x80
[ 1074.549976]  [<ffffffff81078c46>] blocking_notifier_call_chain+0x16/0x20
[ 1074.549981]  [<ffffffff81523409>] __inet_del_ifa+0xf9/0x2a0
[ 1074.549986]  [<ffffffff810cc736>] ? __res_counter_charge+0xf6/0x130
[ 1074.549990]  [<ffffffff815236ba>] inet_rtm_deladdr+0x10a/0x160
[ 1074.549996]  [<ffffffff814bc544>] rtnetlink_rcv_msg+0xa4/0x240
[ 1074.550000]  [<ffffffff814bc4a0>] ? __rtnl_unlock+0x20/0x20
[ 1074.550006]  [<ffffffff814dc8a1>] netlink_rcv_skb+0xb1/0xc0
[ 1074.550010]  [<ffffffff814b90e5>] rtnetlink_rcv+0x25/0x40
[ 1074.550013]  [<ffffffff814dc145>] netlink_unicast+0x145/0x200
[ 1074.550017]  [<ffffffff814dc503>] netlink_sendmsg+0x303/0x400
[ 1074.550023]  [<ffffffff81491e0c>] sock_sendmsg+0x9c/0xd0
[ 1074.550028]  [<ffffffff814926c0>] ? move_addr_to_kernel+0x40/0xa0
[ 1074.550033]  [<ffffffff8149fa39>] ? verify_iovec+0x49/0xd0

We have a quadratic behavior here. 65536*65536 is too big.
