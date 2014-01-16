From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ipv6 addrconfg warn_on hit: WARN_ON(ifp->idev->valid_ll_addr_cnt
 < 0);
Date: Thu, 16 Jan 2014 15:07:01 +0100
Message-ID: <20140116140701.GB7961@minipsycho.orion>
References: <20140116135323.GA7961@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:35315 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbaAPOHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 09:07:08 -0500
Received: by mail-ee0-f47.google.com with SMTP id d49so772197eek.6
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 06:07:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140116135323.GA7961@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 16, 2014 at 02:53:23PM CET, jiri@resnulli.us wrote:
>Hi Hannes.
>
>WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
>
>We did hit once this warning during the tests. The person who hit this
>says that it was during the setup of many macvlan devices.
>
>I examined the code but I'm not sure how this could happen. Looks like a
>race condition between addrconf_dad_completed() and addrconf_ifdown(). 
>Not sure how to easily resolve that though.
>
>Would you please take a look?
>
>Thanks!
>
>Jiri

[16661.669422] Call Trace:
[16661.684417]  [<ffffffff815b4dde>] dump_stack+0x19/0x1b
[16661.714596]  [<ffffffff81058bd1>] warn_slowpath_common+0x61/0x80
[16661.748587]  [<ffffffff81058caa>] warn_slowpath_null+0x1a/0x20
[16661.780334]  [<ffffffff81551e1a>] update_valid_ll_addr_cnt+0x9a/0xa0
[16661.816145]  [<ffffffff81555ca5>] __ipv6_ifa_notify+0xb5/0x2e0
[16661.849222]  [<ffffffff8155819e>] addrconf_ifdown+0x21e/0x3e0
[16661.880245]  [<ffffffff815594be>] addrconf_notify+0x5e/0x430
[16661.912233]  [<ffffffff815662ce>] ? ndisc_netdev_event+0x4e/0x100
[16661.945485]  [<ffffffff815c064c>] notifier_call_chain+0x4c/0x70
[16661.979227]  [<ffffffff81084756>] raw_notifier_call_chain+0x16/0x20
[16662.013434]  [<ffffffff814a5fad>] call_netdevice_notifiers+0x2d/0x60
[16662.051709]  [<ffffffff814a6217>] dev_close_many+0xb7/0x100
[16662.084728]  [<ffffffff814a62c0>] dev_close+0x60/0x80
[16662.114689]  [<ffffffff814a9134>] dev_change_net_namespace+0x94/0x220
[16662.152638]  [<ffffffff814ba043>] do_setlink+0x83/0x9f0
[16662.183447]  [<ffffffff812bae36>] ? nla_parse+0x96/0xe0
[16662.214146]  [<ffffffff814bb614>] rtnl_newlink+0x394/0x5e0
[16662.247097]  [<ffffffff8123cc0e>] ? selinux_capable+0x2e/0x40
[16662.281035]  [<ffffffff814b8009>] rtnetlink_rcv_msg+0x99/0x260
[16662.313053]  [<ffffffff81239e25>] ? sock_has_perm+0x75/0x90
[16662.344678]  [<ffffffff814b7f70>] ? rtnetlink_rcv+0x30/0x30
[16662.375627]  [<ffffffff814d6fc9>] netlink_rcv_skb+0xa9/0xc0
[16662.409066]  [<ffffffff814b7f68>] rtnetlink_rcv+0x28/0x30
[16662.438982]  [<ffffffff814d662d>] netlink_unicast+0xdd/0x190
[16662.470946]  [<ffffffff814d69df>] netlink_sendmsg+0x2ff/0x730
[16662.502797]  [<ffffffff81493289>] sock_sendmsg+0x99/0xd0
[16662.532625]  [<ffffffff8149367c>] ___sys_sendmsg+0x36c/0x380
[16662.564507]  [<ffffffff8149b329>] ? skb_dequeue+0x59/0x70
[16662.596497]  [<ffffffff8115d4b5>] ? handle_mm_fault+0x285/0x3a0
[16662.631456]  [<ffffffff815c0174>] ? __do_page_fault+0x1f4/0x510
[16662.666968]  [<ffffffff811b3a85>] ? d_free+0x55/0x60
[16662.695923]  [<ffffffff811bcc1e>] ? mntput_no_expire+0x3e/0x120
[16662.731922]  [<ffffffff811bcd24>] ? mntput+0x24/0x40
[16662.761353]  [<ffffffff8119f823>] ? __fput+0x183/0x270
[16662.792218]  [<ffffffff81494462>] __sys_sendmsg+0x42/0x80
[16662.824368]  [<ffffffff814944b2>] SyS_sendmsg+0x12/0x20
[16662.855854]  [<ffffffff815c4c99>] system_call_fastpath+0x16/0x1b
[16662.892006] ---[ end trace 9f96f71eeb981f7e ]---
