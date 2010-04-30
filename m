From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 14:24:38 -0700
Message-ID: <87bpd0zl9l.fsf@caffeine.danplanet.com>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
	<4BDB3F07.2030900@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:33404 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757472Ab0D3VYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DL> Is it possible to enter the namespace and dump / restore the
DL> routes with NETLINK_ROUTE from userspace ? Or is it something not
DL> possible ?

I'm sure it would be doable.  However, checkpointing the routes that
way would:

(a) Be inconsistent with how we checkpoint all the other resources,
    including the other network resources we handle from the kernel
    with rtnl
(b) Require merging of the data from the resources saved in userspace
    with those saved in kernelspace
(c) Eliminate the ability for an application to easily checkpoint
    itself by making a single syscall
(d) Require this same sort of jumping back and forth between
    namespaces by the userspace task doing the checkpoint/restart

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
