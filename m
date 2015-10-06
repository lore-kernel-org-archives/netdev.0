From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 11:55:35 -0700
Message-ID: <CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36934 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbbJFSzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:55:36 -0400
Received: by igcpe7 with SMTP id pe7so31414563igc.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:55:35 -0700 (PDT)
In-Reply-To: <20151006204558.5f2f56fc@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 11:45 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 6 Oct 2015 11:28:08 -0700, Pravin Shelar wrote:
>> What do you have in mind? I do not see way to fix this issue in vport-*.c.
>
> It seems to me that e.g. the code you have in vxlan_egress_tun_info in
> drivers/net/vxlan.c can be put into vxlan_get_egress_tun_info in
> net/openvswitch/vport-vxlan.c. vport->dev is guaranteed to be vxlan,
> and the current code accesses netdev_priv(dev) as struct vxlan_dev
> anyway.
>
> This would of course not work if we created lwtunnel interface from the
> ovs user space. But that's not going to happen with kernel 4.3, we'll
> need a way to query datapath for features it supports for this to work

This issue exist for lwtunnel based devices, for vport based tunnels
there is no bug.

> - there's currently no useful way to determine whether the kernel
> supports metadata based vxlan or not. I'm working on a patch to query
> the datapath for the supported features but that's for net-next. Thus
> I think we're safe.
>
We should be able to use lwtunnel devices on 4.3. How about using
tunnel device parameters to detect lwtunnel support. For example in
case of vxlan tunnel IFLA_VXLAN_COLLECT_METADATA flags can confirm
lwtunnel support.
