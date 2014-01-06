From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Mon, 6 Jan 2014 18:38:25 +0200
Message-ID: <CAJZOPZLZNEvao9PxtX78sfpg_4GVamgxNMNU52QQ1aFqAxQDZA@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-g1tsBEG6D0oOmG-J_fz68fr6py2OY6RAtoJHUts7h3g@mail.gmail.com>
	<CAJZOPZJ2DRP13LRzcu__rh=JxY7oAvCQ37dCpmO40ptiRn5hFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45164 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbaAFQi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:38:26 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so18338162pde.13
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 08:38:25 -0800 (PST)
In-Reply-To: <CAJZOPZJ2DRP13LRzcu__rh=JxY7oAvCQ37dCpmO40ptiRn5hFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 3:32 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> As the GUE RFC states, with UDP encapsulation, the encap protocol is
> actually derived from the UDP destination port. With that assumption
> at hand, we can have the udp gro code to export callbacks for upper
> uncapsulation protocol to install a gro handler which has the
> following trivial strucure:
>
> key = <PORT>  data = <gro receive/complete callbacks>

> which plugs nicely into the general framework of the gro stack. The
> udp gro receive code would act as follows
> -- if there's no gro handler set for the packet udp dest port, flush
> - do the normal loop to find match on the packet dest/src udp ports
> - call the protocol (e.g VXLAN) gro receive callback
> This would avoid dealing with sockets etc and be very efficient, makes sense?

Or in short -- the destination udp port takes a similar role to the
ethertype for gro l3 handlers or the ip protocol for gro l4 handlers
and we enable encapsulating protocols to plug into the existing
offload_callbacks framework, simple.
