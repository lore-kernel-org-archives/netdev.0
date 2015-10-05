From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] openvswitch: Fix ovs_vport_get_stats()
Date: Mon, 5 Oct 2015 14:31:50 +0200
Message-ID: <20151005123150.GE5490@pox.localdomain>
References: <1443822994-1928-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tomasz.sawicki@objectiveintegration.uk
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37147 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbbJEPVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:21:08 -0400
Received: by wicfx3 with SMTP id fx3so119603810wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:21:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1443822994-1928-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/15 at 02:56pm, Pravin B Shelar wrote:
> Not every device has dev->tstats set. So when OVS tries to calculate
> vport stats it causes kernel panic. Following patch fixes it by
> using standard API to get net-device stats.
> 
> ---8<---
> Unable to handle kernel paging request at virtual address 766b4008
> Internal error: Oops: 96000005 [#1] PREEMPT SMP
> Modules linked in: vport_vxlan vxlan ip6_udp_tunnel udp_tunnel tun bridge stp llc openvswitch ipv6
> CPU: 7 PID: 1108 Comm: ovs-vswitchd Not tainted 4.3.0-rc3+ #82
> PC is at ovs_vport_get_stats+0x150/0x1f8 [openvswitch]
> <snip>
> Call trace:
>  [<ffffffbffc0859f8>] ovs_vport_get_stats+0x150/0x1f8 [openvswitch]
>  [<ffffffbffc07cdb0>] ovs_vport_cmd_fill_info+0x140/0x1e0 [openvswitch]
>  [<ffffffbffc07cf0c>] ovs_vport_cmd_dump+0xbc/0x138 [openvswitch]
>  [<ffffffc00045a5ac>] netlink_dump+0xb8/0x258
>  [<ffffffc00045ace0>] __netlink_dump_start+0x120/0x178
>  [<ffffffc00045dd9c>] genl_family_rcv_msg+0x2d4/0x308
>  [<ffffffc00045de58>] genl_rcv_msg+0x88/0xc4
>  [<ffffffc00045cf24>] netlink_rcv_skb+0xd4/0x100
>  [<ffffffc00045dab0>] genl_rcv+0x30/0x48
>  [<ffffffc00045c830>] netlink_unicast+0x154/0x200
>  [<ffffffc00045cc9c>] netlink_sendmsg+0x308/0x364
>  [<ffffffc00041e10c>] sock_sendmsg+0x14/0x2c
>  [<ffffffc000420d58>] SyS_sendto+0xbc/0xf0
> Code: aa1603e1 f94037a4 aa1303e2 aa1703e0 (f9400465)
> 
> Reported-by: Tomasz Sawicki <tomasz.sawicki@objectiveintegration.uk>
> Fixes: 8c876639c98 ("openvswitch: Remove vport stats.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
