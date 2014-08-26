From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 00:01:22 +0200
Message-ID: <1409090482.1152.8.camel@localhost>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tushar Shinde <mtk.tushar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52132 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755776AbaHZWBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 18:01:24 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 5668220960
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 18:01:24 -0400 (EDT)
In-Reply-To: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Di, 2014-08-26 at 21:32 +0530, Tushar Shinde wrote:
> Hello NetDev,
> 
> I am facing problem where if ipv6 route (outside to current subnet) is
> reachable only if route is present in main table. Policy based routes
> are not working.
> 
> Following is my setup,
> 
> eth0   inet6 2001:1::10/120 scope global
> eth1   inet6 2001:1::11/120 scope global
> 2001:1::1 is gateway
> 2.6.32-431.11.2.el6.x86_64 kernel (I tried on 3.x also)
> 
> [root@ipv6node1 ~]# ip -6 route show tab 1
> 2001:1::/120 dev eth0  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
> default via 2001:1::1 dev eth0  metric 1024  mtu 1500 advmss 1440
> hoplimit 4294967295
> [root@ipv6node1 ~]#
> [root@ipv6node1 ~]# ip -6 route show tab 2
> 2001:1::/120 dev eth1  metric 1024  mtu 1500 advmss 1440 hoplimit 4294967295
> default via 2001:1::1 dev eth1  metric 1024  mtu 1500 advmss 1440
> hoplimit 4294967295
> [root@ipv6node1 ~]#
> [root@ipv6node1 ~]# ip -6 rule show
> 0:    from all lookup local
> 16383:    from 2001:1::10 lookup 1
> 16383:    from 2001:1::11 lookup 2
> 32766:    from all lookup main
> [root@ipv6node1 ~]#
> 
> If I add default vai eth0 only ip of eth0 is reachable from outside or
> eth1 dont work. In above setup default route is not present.
> 
> But default entry in "table" is never getting used to resolve route
> 
> [root@ipv6node1 ~]# ping6 -I eth0 2001:2::20
> connect: Network is unreachable
> [root@ipv6node1 ~]#
> [root@ipv6node1 ~]# ping6 -I eth1 2001:2::20
> connect: Network is unreachable
> [root@ipv6node1 ~]#

ping6 selects the ipv6 address based on netlink route lookup given the
specified interface but without setting the source address. That said,
it is probable that the rule lookup happens with a completely different
ipv6 address. Please verify this. ping6 -I also accepts a source ipv6
address, can you try this?

Otherwise please specify with which 3.x kernel you tested this.

Thanks,
Hannes
