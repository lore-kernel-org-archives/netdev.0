From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: RtNetlink in wireless.c and netlink_broadcast(uevent_sock,...) - newbie
Date: Mon, 1 May 2006 10:50:03 -0700
Message-ID: <20060501175003.GA32508@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:38284 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S932174AbWEARuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 13:50:04 -0400
Received: from cacrelint01.ptp.hp.com (cacrelint01.ptp.hp.com [15.1.29.21])
	by palrel13.hp.com (Postfix) with ESMTP id CF81D35B84
	for <netdev@vger.kernel.org>; Mon,  1 May 2006 10:50:03 -0700 (PDT)
Received: from hplns3.hpl.hp.com (hplns3.hpl.hp.com [15.0.48.4])
	by cacrelint01.ptp.hp.com (Postfix) with ESMTP id AA4D834033
	for <netdev@vger.kernel.org>; Mon,  1 May 2006 10:50:03 -0700 (PDT)
Received: from bougret.hpl.hp.com (bougret.hpl.hp.com [15.9.72.130])
	by hplns3.hpl.hp.com (8.13.1/8.13.1/HPL-PA Hub) with ESMTP id k41Ho35l024422
	for <netdev@vger.kernel.org>; Mon, 1 May 2006 10:50:03 -0700 (PDT)
Received: from jt by bougret.hpl.hp.com with local (Exim 4.50)
	id 1FacX5-0008Sb-8B
	for netdev@vger.kernel.org; Mon, 01 May 2006 10:50:03 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xu Nakajima wrote :
> 
> Hello,
> 
> I saw that in the wireless linux stack, there is usage
> 
> of sending messages to user space via the RtNetlink
> event channel : 
> in net/core/wireless.c,  wireless_send_event() method
> calls rtmsg_iwinfo() which calls
> netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK,
> GFP_ATOMIC); (it fills a struct with 
> rtnetlink_fill_iwinfo before).
> 
> On the other hand, I see that for example, in the case
> of 
> sending messeges to userspace udev socket, the
> netlink_broadcast() call is with a different
> mecahinsm;  
> In lib/kobject_uevent.c, there is the following call
> netlink_broadcast(uevent_sock, skb, 0, 1, GFP_KERNEL);
> 
> Is there something special about RtNetlink event
> channel
> which makes it needed fot wireless.c (for example)? 
> While udev can use some other mechanism ?
> What is special about RtNetlink event channel
> in comaprison to non RtNetlink channels?

	Netlink is a generic socket mechanism. On top of Netlink, you
can have multiple types of sockets, the same way that on top of TCP
sockets you can implement various protocols, such as HTTP, NFS, SSH...
	RtNetlink was the first Netlink protocol implemented and is
the Netlink protocol used to configure network interfaces. In the file
net/core/rtnetlink.c, you will find that there are many actions that
generates RtNetlink events. Together with wireless events, they give
you a very detailed view of what's happening with network interfaces.
	The udev-netlink protocol is quite recent and a completely
different Netlink ptotocol that uses a different packet format. As far
as exporting network information, it is very crude, because the goal
of udev is not managing network interfaces. Yes, udev does duplicate
some RtNetlink events, but the overlap is not so much, so that's ok.

	Good luck...

	Jean
