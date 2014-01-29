From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Wed, 29 Jan 2014 12:04:01 +0100
Message-ID: <20140129110401.GA25336@order.stressinduktion.org>
References: <1390810971-23959-1-git-send-email-fw@strlen.de> <1390810971-23959-2-git-send-email-fw@strlen.de> <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com> <20140128002707.GA12308@order.stressinduktion.org> <20140129105347.GF30123@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44114 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbaA2LED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 06:04:03 -0500
Content-Disposition: inline
In-Reply-To: <20140129105347.GF30123@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 11:53:47AM +0100, Florian Westphal wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > > TCP stream not using DF flag are very unlikely to care if we adjust
> > > their MTU (lowering gso_size) at this point ?
> > 
> > UDP shouldn't be a problem, too.
> 
> Sorry for late reply, but how can this be safe for UDP?
> We should make sure that peer sees original, unchanged datagram?

Peer as in original destination? Of course, we must not alter the datagram but
can only do fragmentation or send back frag_needed.

> And only solution for UDP that I can see is to do sw segmentation (i.e.
> create ip fragments).

Hardware(-UFO) would do fragmentation in hardware, too, because there is
no other way to split UDP data in any other way. If UFO is not supported
manual sw segmentation would create the required fragments in output
path, too.

Greetings,

  Hannes
