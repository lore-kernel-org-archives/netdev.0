From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
	MAC address change
Date: Mon, 24 Dec 2007 09:50:59 -0500
Message-ID: <1198507860.9642.53.camel@localhost>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <E1J6RPh-0004mf-00@gondolin.me.apana.org.au>
	 <31436f4a0712240538n1b65c2a8u35109ce4c69a00d5@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:42362 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912AbXLXOvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 09:51:05 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2728333wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 06:51:04 -0800 (PST)
In-Reply-To: <31436f4a0712240538n1b65c2a8u35109ce4c69a00d5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-24-12 at 15:38 +0200, David Shwatrz wrote:
> Hello,
> 
> First, it indeed can be handled by user space. (even though it should
> be done twice, once for ifconig of net-tools  and once for ip of
> iproute2) 

it needs to be done once only: reacting to netlink events when MAC
address changes.

> / However, we have already
> methods which deal with bringing down an interface - neigh_ifdown(),
> and changing MAC address of an interface (neigh_changeaddr). So why
> not do it from the kernel ?

Herbert, i agree with you that userspace is the best spot for this[1];
we unfortunately have precedence already on the kernel sending arps with
bonding when link status changes (that was added recently).
So it sounds reasonable to have this patch in the kernel as well.

cheers,
jamal

[1] Things like these tend to be very policy rich and thats why user
space is the best spot for them.
I have infact implemented this feature in user space in some random box
i have where i failover MACs for HA reasons. Depending on how much
traffic there is on the wire, arps do get dropped.
One of the hardest things to decide on was how many times to retry the
grat arp sending and what the timeout would be between each sent
gratarp. 
The earlier patch posted didnt consider this but would be nice to have a
couple of sysctls to add the two parameters if this makes it in.

