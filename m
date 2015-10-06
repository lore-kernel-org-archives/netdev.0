From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 20:45:58 +0200
Message-ID: <20151006204558.5f2f56fc@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266AbbJFSqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 14:46:02 -0400
In-Reply-To: <CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2015 11:28:08 -0700, Pravin Shelar wrote:
> What do you have in mind? I do not see way to fix this issue in vport-*.c.

It seems to me that e.g. the code you have in vxlan_egress_tun_info in
drivers/net/vxlan.c can be put into vxlan_get_egress_tun_info in
net/openvswitch/vport-vxlan.c. vport->dev is guaranteed to be vxlan,
and the current code accesses netdev_priv(dev) as struct vxlan_dev
anyway.

This would of course not work if we created lwtunnel interface from the
ovs user space. But that's not going to happen with kernel 4.3, we'll
need a way to query datapath for features it supports for this to work
- there's currently no useful way to determine whether the kernel
supports metadata based vxlan or not. I'm working on a patch to query
the datapath for the supported features but that's for net-next. Thus
I think we're safe.

 Jiri

-- 
Jiri Benc
