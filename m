From: Vincent Bernat <bernat@luffy.cx>
Subject: IPv6 multipath routes
Date: Thu,  6 Sep 2012 19:30:48 +0200
Message-ID: <1346952649-5716-1-git-send-email-bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:42670 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759426Ab2IFRsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:48:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

It appears that "ip -6 route add" expects IPv4 addresses with nexthop directives:

$ ip -6 route add to 2a01:c9c0:a1:982::/64 proto bird \
   nexthop via fe80::ea39:35ff:febd:f9e dev bai2.2008 weight 1 \
   nexthop via fe80::ea39:35ff:febd:fd6 dev bai1.2009 weight 1
Error: an IP address is expected rather than "fe80::ea39:35ff:febd:f9e"

The following patch fix this problem. However, it does not work. I now have:
 RTNETLINK answers: No such device

I have little knowledge of netlink so it is likely that my patch is
buggy. However, I have found this problem by trying to debug what
appears to be a valid netlink message refused by the kernel with the
same error. Therefore, I suspect that there is also a bug in the kernel.
