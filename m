From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 18:16:19 -0500
Message-ID: <1383002179.28991.14.camel@dcbw.foobar.com>
References: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
	 <20131027132941.GA1443@minipsycho.orion>
	 <20131027164835.GB4714@order.stressinduktion.org>
	 <20131028.171725.1076499130782328273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618Ab3J1XRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 19:17:32 -0400
In-Reply-To: <20131028.171725.1076499130782328273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-28 at 17:17 -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 27 Oct 2013 17:48:35 +0100
> 
> > A temporary address is also bound to a non-privacy public address so
> > it's lifetime is determined by its lifetime (e.g. if you switch the
> > network and don't receive on-link information for that prefix any
> > more). NetworkManager would have to take care about that, too. It is
> > just a question of what NetworkManager wants to handle itself or lets
> > the kernel handle for it.
> 
> How much really needs to be in userspace to implement RFC4941?
> 
> I don't like the idea that even for a fully up and properly
> functioning link, if NetworkManager wedges then critical things like
> temporary address (re-)generation, will cease.

Honestly, I'd be completely happy to leave temporary address handling up
to the kernel and *not* do it in userspace; the kernel already has all
the code.  There are two problems with that though, (a) it's tied to
in-kernel RA handling, and (b) it's controlled by a CONFIG option.  Both
these are solvable.

First off, what's the reasoning behind having IPv6 privacy as a config
option?  It's off-by-default and must be explicitly turned on, so is
there any harm in removing the config?  Or is it just for
smallest-kernel-ever folks?

Would a new IFA_F_MANAGE_TEMP (or better name) work here, indicating
that for some new static address, that the kernel should create and
manage the temporary privacy addresses associated with its prefix?

Dan

> All that seems to matter is the secret used to generate the temporary
> address sequence, and perhaps things like site specific lifetime
> parameters.  These are things userland can send to the kernel in
> netlink messages.
> 
> Full disclosure that I am saying this from the perspective of someone
> who believes that one of the biggest mistakes ever was allowing the
> core of DHCP to be done in userspace.
> 
> Right now every ipv4 DHCP user ends up with their interface in
> promiscuous mode.  The DHCP client implementations are huge non-
> trivial bodies of code, and getting them to adopt the changes necessary
> to not put the interface in promiscuous mode is harder than pulling
> teeth.
> 
> If at least the DHCP protocol communications part were in the kernel,
> on the other hand, we could remove the problem quite swiftly.
> 
> This problem has existed for more than a decade, btw.  There simply
> exists no will to fix it properly, even after all this time, because
> breaking the ice on those DHCP client code bases in userbase is hard.
> 
> So I want to see less fundamental stuff about interface configuration
> and address assignment in userland, not more.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
