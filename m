From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: add link local route when local addr is any
Date: Mon, 17 Feb 2014 14:09:20 -0500 (EST)
Message-ID: <20140217.140920.2121605616455173237.davem@davemloft.net>
References: <5301E59F.5090506@6wind.com>
	<1392643341-4288-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sesse@samfundet.no, hannes@stressinduktion.org,
	itk-intern@samfundet.no, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaBQTJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 14:09:23 -0500
In-Reply-To: <1392643341-4288-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 17 Feb 2014 14:22:21 +0100

> This bug was reported by Steinar H. Gunderson and was introduced by commit
> f7cb8886335d ("sit/gre6: don't try to add the same route two times").
> 
> root@morgental:~# ip tunnel add foo mode gre remote 1.2.3.4 ttl 64
> root@morgental:~# ip link set foo up mtu 1468
> root@morgental:~# ip -6 route show dev foo
> fe80::/64  proto kernel  metric 256
> 
> but after the above commit, no such route shows up.
> 
> There is no link local route because dev->dev_addr is 0 (because local ipv4
> address is 0), hence no link local address is configured.
> 
> In this scenario, the link local address is added manually: 'ip -6 addr add
> fe80::1 dev foo' and because prefix is /128, no link local route is added by the
> kernel.
> 
> Even if the right things to do is to add the link local address with a /64
> prefix, we need to restore the previous behavior to avoid breaking userpace.
> 
> Reported-by: Steinar H. Gunderson <sesse@samfundet.no>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
