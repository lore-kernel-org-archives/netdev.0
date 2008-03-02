From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
 addresses
Date: Mon, 03 Mar 2008 03:02:39 +0900 (JST)
Message-ID: <20080303.030239.105475439.yoshfuji@linux-ipv6.org>
References: <20080221100842.GA24905@verkkotelakka.net>
	<20080302.213902.68664760.yoshfuji@linux-ipv6.org>
	<20080302165453.GP32279@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jmtapio@verkkotelakka.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53629 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbYCBSBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 13:01:38 -0500
In-Reply-To: <20080302165453.GP32279@verkkotelakka.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080302165453.GP32279@verkkotelakka.net> (at Sun, 2 Mar 2008 18:54:53 +0200), Juha-Matti Tapio <jmtapio@verkkotelakka.net> says:

> > Is this really required?
> > I believe address labels (rule 6) should work, no?
> 
> The corner case that I run into was like this (using HIPL):
> 
> $ ip -6 addr
> 1: lo: <LOOPBACK,UP,10000> mtu 16436
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
>     inet6 2002:4fab:e944:1100::1/64 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::2c0:4fff:fe17:ecd9/64 scope link
>        valid_lft forever preferred_lft forever
> 3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,10000> mtu 1500 qlen 100
>     inet6 fe80::2/64 scope link
>        valid_lft forever preferred_lft forever
> 8: dummy0: <BROADCAST,NOARP,UP,10000> mtu 1500
>     inet6 2001:1c:ed0f:6dda:e9c3:8921:2ee7:7a52/28 scope global
>        valid_lft forever preferred_lft forever
> [...]
> 
> $ ip -6 route
> 2001:1c:ed0f:6dda:e9c3:8921:2ee7:7a52 dev dummy0  metric 1024  expires 8567991sec mtu 1500 advmss 1440 hoplimit 4294967295
> [...]
> 2002:4fab:e944:1100::/64 dev eth0  metric 256  expires 8211503sec mtu 1500 advmss 1440 hoplimit 4294967295
> [...]
> default via fe80::1 dev tun0  metric 512  expires 8211512sec mtu 1500 advmss 1440 hoplimit 4294967295
> [...]
> 
> In this case if I try to connect to www.ripe.net alias
> 2001:610:240:11::c100:1319, there is no local source address that
> matches the destination's label and the outgoing interface does not
> have any public addresses. Therefore the 8th rule applies and the HIT
> (2001:...) wins and the destination can not understand the source
> address.
> 
> I'm not particularly happy with the above mentioned second patch, but
> I could not come up with a more elegant fix.

And then, what address should you use? 6to4 address?

Then, what you should do is to appropriately configure your policy
(label) table via the addrlabel subsystem.

Or, if ORCHID address can never communicate with non-ORCHID
address, we could have it in the rule 0 (not 8 minus).

What do you think?

--yoshfuji
