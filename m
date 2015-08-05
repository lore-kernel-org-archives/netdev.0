From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] openvswitch: Use regular GRE net_device
 instead of vport
Date: Tue, 4 Aug 2015 21:07:52 -0700
Message-ID: <20150805040749.GA50788@Alexeis-MacBook-Pro.local>
References: <1438730555-3142-1-git-send-email-pshelar@nicira.com>
 <20150805022701.GA50708@Alexeis-MacBook-Pro.local>
 <CALnjE+rwf1ytPScx3Ok8QGURwR11KN0AEATxEYG04_rEJYL4gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:34551 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbbHEEHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 00:07:55 -0400
Received: by ykax123 with SMTP id x123so26066479yka.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 21:07:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+rwf1ytPScx3Ok8QGURwR11KN0AEATxEYG04_rEJYL4gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 07:50:40PM -0700, Pravin Shelar wrote:
> 
> I am planning on adding the ip_gre netlink interface later on. OVS
> userspace needs same interface to directly create the GRE device
> without vport-gre module. vport-gre module is compatibility code. If
> you want I can do it in same patch.

I think it has to be part of the same patch set especially if ovs
userspace is going to create gre netdev directly.
Adding IFLA_GRE_COLLECT_METADATA flag will let anyone use this gre tunnel
with normal routing that already understands tunnel metadata and
if routing is working then bpf helpers will work with it seamlessly as well.

Have another question:
+ info->key.tun_flags = tpi->flags & (TUNNEL_CSUM | TUNNEL_KEY);
why keep CSUM flag ?
Current ip_tunnel_key doesn't have csum field, so gre csum gets lost
after decap anyway?

Also I think FLOWBASED is a bad name both here and in vxlan.
Tunnel that understands metadata on tx/rx has nothing to do with flows.
I'm thinking to combine IFLA_VXLAN_FLOWBASED + IFLA_VXLAN_COLLECT_METADATA
into one IFLA_VXLAN_COLLECT_METADATA while it's not too late.
