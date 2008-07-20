From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG, NET] deadlock tearing down a bridged interface
Date: Sat, 19 Jul 2008 23:07:51 -0700
Message-ID: <20080719230751.4cbc8c27@extreme>
References: <20080718073724.GA5802@disturbed>
	<4880BA7A.3020909@candelatech.com>
	<20080719011709.GA5947@disturbed>
	<48821DEF.1040306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55344 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbYGTGHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2008 02:07:53 -0400
In-Reply-To: <48821DEF.1040306@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks something related icmp6_dst_alloc creating a reference
(in rt6_info), but these entries are not being cleaned up.
Possibly related to icmp6_dst_gc.

This is what happens if a bridge is created, then brought up.
and then bridge module is attempted to be removed.

[  148.814733] br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM feature.
[  148.814944] br0: dev_hold 1 register_netdevice
[  148.814972] br0: dev_hold 2 neigh_parms_alloc
[  148.814976] br0: dev_hold 3 inetdev_init
[  148.815875] br0: dev_hold 4 neigh_parms_alloc
[  148.815880] br0: dev_hold 5 ipv6_add_dev
[  165.885715] br0: dev_hold 6 dev_get_by_index
[  165.886940] br0: dev_hold 7 dev_get_by_index
[  165.886947] br0: dev_put 7 free_fib_info
[  165.886952] br0: dev_hold 7 fib_check_nh
[  165.886986] br0: dev_hold 8 fib_check_nh
[  165.886991] br0: dev_put 8 free_fib_info
[  165.887006] br0: dev_hold 8 fib_check_nh
[  165.887011] br0: dev_put 8 free_fib_info
[  165.887026] br0: dev_hold 8 fib_check_nh
[  165.887030] br0: dev_put 8 free_fib_info
[  165.887043] br0: dev_hold 8 dev_get_by_index
[  165.887060] br0: dev_hold 9 dev_get_by_index
[  165.887084] br0: dev_hold 10 dev_get_by_index
[  165.887089] br0: dev_put 10 dst_destroy
[  165.888480] br0: dev_put 9 free_fib_info
[  165.888497] br0: dev_put 8 free_fib_info
[  165.889359] br0: dev_hold 8 dev_get_by_index
[  165.889378] br0: dev_hold 9 fib_check_nh
[  165.889394] br0: dev_hold 10 fib_check_nh
[  165.889399] br0: dev_put 10 free_fib_info
[  165.889412] br0: dev_hold 10 fib_check_nh
[  165.889417] br0: dev_put 10 free_fib_info
[  165.889432] br0: dev_hold 10 fib_check_nh
[  165.889437] br0: dev_put 10 free_fib_info
[  165.894973] br0: dev_hold 10 icmp6_dst_alloc
[  165.894983] br0: dev_hold 11 neigh_create
[  165.895005] br0: dev_hold 12 dev_get_by_index
[  165.895011] br0: dev_hold 13 __mkroute_output
[  165.895017] br0: dev_hold 14 neigh_create
[  165.895022] br0: dev_put 14 ip_route_output_slow
[  166.086518] br0: dev_hold 14 ip_dev_find
[  166.086524] br0: dev_put 14 ip_route_output_slow
[  166.086527] br0: dev_hold 14 dev_get_by_index
[  166.086530] br0: dev_hold 15 __mkroute_output
[  166.086536] br0: dev_hold 16 neigh_create
[  166.086539] br0: dev_put 16 ip_route_output_slow
[  166.086564] br0: dev_hold 16 netif_rx
[  166.086575] br0: dev_put 16 process_backlog
[  166.110517] br0: dev_hold 16 netif_rx
[  166.110528] br0: dev_put 16 process_backlog
[  166.342516] br0: dev_hold 16 netif_rx
[  166.342527] br0: dev_put 16 process_backlog
[  166.414459] br0: dev_hold 16 icmp6_dst_alloc
[  166.414465] br0: dev_hold 17 neigh_create
[  166.598525] br0: dev_hold 18 netif_rx
[  166.598537] br0: dev_put 18 process_backlog
[  166.798613] br0: dev_hold 18 netif_rx
[  166.798624] br0: dev_put 18 process_backlog
[  167.250500] br0: dev_hold 18 netif_rx
[  167.250511] br0: dev_put 18 process_backlog
[  167.414464] br0: dev_hold 18 icmp6_dst_alloc
[  167.414470] br0: dev_hold 19 neigh_create
[  167.610510] br0: dev_hold 20 netif_rx
[  167.610521] br0: dev_put 20 process_backlog
[  167.610656] br0: dev_hold 20 netif_rx
[  167.610664] br0: dev_put 20 process_backlog
[  167.866495] br0: dev_hold 20 netif_rx
[  167.866506] br0: dev_put 20 process_backlog
[  167.938575] br0: dev_hold 20 netif_rx
[  167.938586] br0: dev_put 20 process_backlog
[  168.118511] br0: dev_hold 20 netif_rx
[  168.118522] br0: dev_put 20 process_backlog
[  168.118662] br0: dev_hold 20 netif_rx
[  168.118670] br0: dev_put 20 process_backlog
[  168.322535] br0: dev_hold 20 netif_rx
[  168.322546] br0: dev_put 20 process_backlog
[  169.390505] br0: dev_hold 20 netif_rx
[  169.390516] br0: dev_put 20 process_backlog
[  169.462506] br0: dev_hold 20 netif_rx
[  169.462517] br0: dev_put 20 process_backlog
[  170.078564] br0: dev_hold 20 netif_rx
[  170.078576] br0: dev_put 20 process_backlog
[  171.414377] br0: dev_hold 20 icmp6_dst_alloc
[  171.602486] br0: dev_hold 21 netif_rx
[  171.602499] br0: dev_put 21 process_backlog
[  172.122369] br0: dev_hold 21 icmp6_dst_alloc
[  175.414312] br0: dev_hold 22 icmp6_dst_alloc
[  176.414294] br0: no IPv6 routers present
[  179.754147] br0: dev_hold 23 ip_dev_find
[  179.754153] br0: dev_put 23 ip_route_output_slow
[  179.754157] br0: dev_hold 23 ip_route_output_slow
[  179.754162] br0: dev_hold 24 __mkroute_output
[  179.754168] br0: dev_hold 25 neigh_create
[  179.754174] br0: dev_put 25 ip_route_output_slow
[  179.754202] br0: dev_hold 25 netif_rx
[  179.754214] br0: dev_put 25 process_backlog
[  179.754239] br0: dev_hold 25 netif_rx
[  179.754248] br0: dev_put 25 process_backlog
[  179.754268] br0: dev_hold 25 netif_rx
[  179.754277] br0: dev_put 25 process_backlog
[  179.754297] br0: dev_hold 25 netif_rx
[  179.754306] br0: dev_put 25 process_backlog
[  179.754323] br0: dev_hold 25 netif_rx
[  179.754331] br0: dev_put 25 process_backlog
[  179.754707] br0: dev_hold 25 netif_rx
[  179.754716] br0: dev_put 25 process_backlog
[  181.754187] br0: dev_hold 25 netif_rx
[  181.754195] br0: dev_put 25 process_backlog
[  181.754209] br0: dev_hold 25 netif_rx
[  181.754216] br0: dev_put 25 process_backlog
[  181.754230] br0: dev_hold 25 netif_rx
[  181.754238] br0: dev_put 25 process_backlog
[  181.754252] br0: dev_hold 25 netif_rx
[  181.754260] br0: dev_put 25 process_backlog
[  181.754273] br0: dev_hold 25 netif_rx
[  181.754280] br0: dev_put 25 process_backlog
[  181.754458] br0: dev_hold 25 netif_rx
[  181.754467] br0: dev_put 25 process_backlog
[  181.754481] br0: dev_hold 25 netif_rx
[  181.754489] br0: dev_put 25 process_backlog
[  181.754503] br0: dev_hold 25 netif_rx
[  181.754510] br0: dev_put 25 process_backlog
[  181.754524] br0: dev_hold 25 netif_rx
[  181.754532] br0: dev_put 25 process_backlog
[  181.754546] br0: dev_hold 25 netif_rx
[  181.754554] br0: dev_put 25 process_backlog
[  183.754140] br0: dev_hold 25 netif_rx
[  183.754149] br0: dev_put 25 process_backlog
[  183.754163] br0: dev_hold 25 netif_rx
[  183.754172] br0: dev_put 25 process_backlog
[  183.754185] br0: dev_hold 25 netif_rx
[  183.754193] br0: dev_put 25 process_backlog
[  183.754206] br0: dev_hold 25 netif_rx
[  183.754214] br0: dev_put 25 process_backlog
[  183.754227] br0: dev_hold 25 netif_rx
[  183.754235] br0: dev_put 25 process_backlog
[  188.854636] br0: dev_put 24 free_fib_info
[  188.855481] br0: dev_put 23 dst_destroy
[  188.855547] br0: dev_put 22 dst_destroy
[  188.855610] br0: dev_put 21 dst_destroy
[  188.855675] br0: dev_put 20 neigh_destroy
[  188.855739] br0: dev_put 19 dst_destroy
[  188.855803] br0: dev_put 18 neigh_destroy
[  188.855866] br0: dev_put 17 dst_destroy
[  188.855931] br0: dev_put 16 neigh_destroy
[  188.855994] br0: dev_put 15 dst_destroy
[  188.856075] br0: dev_put 14 dst_destroy
[  188.856145] br0: dev_put 13 dst_destroy
[  188.865683] br0: dev_put 12 neigh_destroy
[  188.865750] br0: dev_put 11 dst_destroy
[  188.865813] br0: dev_put 10 neigh_destroy
[  188.865876] br0: dev_put 9 dst_destroy
[  188.866002] br0: dev_put 8 neigh_destroy
[  188.866065] br0: dev_put 7 dst_destroy
[  243.751561] br0: dev_hold 7 ip_dev_find
[  243.751564] br0: dev_put 7 ip_route_output_slow
