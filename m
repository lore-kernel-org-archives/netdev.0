From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: IPv6 unique local address flushes on up/down
Date: Tue, 25 Mar 2008 18:11:38 +0300
Message-ID: <1206457898.14357.16.camel@iris.sw.ru>
References: <200803251557.21563.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hostap@lists.shmoo.com, netdev@vger.kernel.org
To: Chr <chunkeey@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23695 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754174AbYCYPLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 11:11:16 -0400
In-Reply-To: <200803251557.21563.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-03-25 at 15:57 +0100, Chr wrote:
> Hi,
> 
> I have a problem with hostapd & IPv6... 
> 
> as you might know, or not... hostapd needs to initialize 
> the interface (e.g it changes it to master/accesspoint mode,
> which can only be done if the interface is down)... 
> 
> However if the interface is brought down & up again (e.g whenever
> hostap starts or restarts)... the IPv6 logic flushes the unique-local ipv6 
> address that I gave it (by hand) with ip addr add fddb:xyz...::1//64 dev ath0 
> in /etc/network/interfaces ifup script (-probably debian specific-).
> 
> And that's bad, because bind9,ISC dhcp-server v4.1 and racoon(IPsec/VPN)
> needs a static address for their records/lease database and configuration...
> 
> This wasn't problem with the old IPv4... because there the 
> 10.x.y.z or 192.168.a.b addresses aren't deleted when the interface 
> was _reinitialized_ by the hostap...
> 
> Now my question, which _one_ should we fix the applications or the stack?!
> I think the network stack, but I don't know if there are RFC about this 
> issue... or is there already some flag/setting which I've missed so far?  

On interface down IPv6 stack unconditionally deletes all addresses from
the interface in the addrconf_ifdown routine.

