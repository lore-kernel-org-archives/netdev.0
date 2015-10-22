From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 20:56:29 +0200
Message-ID: <20151022185629.GI23554@pox.localdomain>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
 <5628F81D.1070009@6wind.com>
 <20151022170100.1e45a8b8@griffin>
 <20151022164558.GH23554@pox.localdomain>
 <1445534516.240647.417579361.507D42D3@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thaller@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37561 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073AbbJVS4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 14:56:32 -0400
Received: by wicfv8 with SMTP id fv8so2044601wic.0
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 11:56:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445534516.240647.417579361.507D42D3@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/15 at 07:21pm, Hannes Frederic Sowa wrote:
> Hi Thomas,
> 
> On Thu, Oct 22, 2015, at 18:45, Thomas Graf wrote:
> > I understand the race but when does it occur? Whoever creates
> > the original interface owns it and is responsible for its
> > lifecycle. *Iff* for some reason multiple entities manipulate
> > the interface, then it's probably a lot safer to just use flock
> > or something similar to serialize access entirely in user space.
> 
> This only works if all networking configuration programs would
> standardize on the same flock. Also, under memory pressure we lose
> netlink monitor messages, so we need to deal with timeouts and retries
> and manual sync up on the networking configuration, which makes this
> scheme a lot harder. For normal socket io, where we specify e.g. ifindex
> in sin6_addr, this is not really usable at all.

Again, what is the scenario where this happens? Is this being
hit or are we talking theoretical races? I'd like to understand
the background of this.
