From: Rick Jones <rick.jones2@hp.com>
Subject: Compilation error on freshly pulled net-next?
Date: Fri, 05 Sep 2014 14:47:43 -0700
Message-ID: <540A2F7F.8060809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t1526.atlanta.hp.com ([15.193.200.69]:15455 "EHLO
	g6t1526.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbaIEVrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was going to do some additional "floor sweeping" and put=20
dev_consume_skb_any() into another driver or two, so I did a fresh pull=
=20
of net-next and a make and got:

   CC      net/core/rtnetlink.o
net/core/rtnetlink.c: In function =91if_nlmsg_size=92:
net/core/rtnetlink.c:868:84: error: expected =91;=92 before =91J=92
net/core/rtnetlink.c: At top level:
net/core/rtnetlink.c:420:15: warning: =91rtnl_link_get_size=92 defined =
but=20
not used [-Wunused-function]
net/core/rtnetlink.c:497:15: warning: =91rtnl_link_get_af_size=92 defin=
ed=20
but not used [-Wunused-function]


Looks like someone slipped a J in there and confused things:

                + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS=
=20
+ IFLA_PORT_SELF */J            + rtnl_link_get_size(dev) /*=20
IFLA_LINKINFO */
                + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */

(hopefully my mail client won't have mangled things too badly)

What is odd though is a git diff after I've replaced that 'J' with a=20
return isn't giving me any output.

rick jones
