From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 17:17:25 -0400 (EDT)
Message-ID: <20131028.171725.1076499130782328273.davem@davemloft.net>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
	<20131027132941.GA1443@minipsycho.orion>
	<20131027164835.GB4714@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, vyasevich@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3J1VRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 17:17:30 -0400
In-Reply-To: <20131027164835.GB4714@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 27 Oct 2013 17:48:35 +0100

> A temporary address is also bound to a non-privacy public address so
> it's lifetime is determined by its lifetime (e.g. if you switch the
> network and don't receive on-link information for that prefix any
> more). NetworkManager would have to take care about that, too. It is
> just a question of what NetworkManager wants to handle itself or lets
> the kernel handle for it.

How much really needs to be in userspace to implement RFC4941?

I don't like the idea that even for a fully up and properly
functioning link, if NetworkManager wedges then critical things like
temporary address (re-)generation, will cease.

All that seems to matter is the secret used to generate the temporary
address sequence, and perhaps things like site specific lifetime
parameters.  These are things userland can send to the kernel in
netlink messages.

Full disclosure that I am saying this from the perspective of someone
who believes that one of the biggest mistakes ever was allowing the
core of DHCP to be done in userspace.

Right now every ipv4 DHCP user ends up with their interface in
promiscuous mode.  The DHCP client implementations are huge non-
trivial bodies of code, and getting them to adopt the changes necessary
to not put the interface in promiscuous mode is harder than pulling
teeth.

If at least the DHCP protocol communications part were in the kernel,
on the other hand, we could remove the problem quite swiftly.

This problem has existed for more than a decade, btw.  There simply
exists no will to fix it properly, even after all this time, because
breaking the ice on those DHCP client code bases in userbase is hard.

So I want to see less fundamental stuff about interface configuration
and address assignment in userland, not more.
