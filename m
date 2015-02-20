From: Andy Zhou <azhou@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix net exit.
Date: Thu, 19 Feb 2015 17:40:03 -0800
Message-ID: <CACzMAJKM1ob4sNinDeZfXjK0GuFnQeFWawMyC-qnCJeqGrytnw@mail.gmail.com>
References: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>, amuller@redhat.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:50933 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753017AbbBTBkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 20:40:05 -0500
Received: by mail-oi0-f46.google.com with SMTP id x69so280246oia.5
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 17:40:04 -0800 (PST)
In-Reply-To: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 11:23 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Open vSwitch allows moving internal vport to different namespace
> while still connected to the bridge. But when namespace deleted
> OVS does not detach these vports, that results in dangling
> pointer to netdevice which causes kernel panic as follows.
> This issue is fixed by detaching all ovs ports from the deleted
> namespace at net-exit.
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
> IP: [<ffffffffa0aadaa5>] ovs_vport_locate+0x35/0x80 [openvswitch]
> Oops: 0000 [#1] SMP
> Call Trace:
>  [<ffffffffa0aa6391>] lookup_vport+0x21/0xd0 [openvswitch]
>  [<ffffffffa0aa65f9>] ovs_vport_cmd_get+0x59/0xf0 [openvswitch]
>  [<ffffffff8167e07c>] genl_family_rcv_msg+0x1bc/0x3e0
>  [<ffffffff8167e319>] genl_rcv_msg+0x79/0xc0
>  [<ffffffff8167d919>] netlink_rcv_skb+0xb9/0xe0
>  [<ffffffff8167deac>] genl_rcv+0x2c/0x40
>  [<ffffffff8167cffd>] netlink_unicast+0x12d/0x1c0
>  [<ffffffff8167d3da>] netlink_sendmsg+0x34a/0x6b0
>  [<ffffffff8162e140>] sock_sendmsg+0xa0/0xe0
>  [<ffffffff8162e5e8>] ___sys_sendmsg+0x408/0x420
>  [<ffffffff8162f541>] __sys_sendmsg+0x51/0x90
>  [<ffffffff8162f592>] SyS_sendmsg+0x12/0x20
>  [<ffffffff81764ee9>] system_call_fastpath+0x12/0x17
>
> Reported-by: Assaf Muller <amuller@redhat.com>
> Fixes: 46df7b81454("openvswitch: Add support for network namespaces.")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Would a  similar issue exist for veth type of device?
After cleaning up the vports, would user space still make reference to ports?
