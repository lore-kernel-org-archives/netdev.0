From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 19:21:49 -0700
Message-ID: <1459563709.6473.305.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160401.152405.915323132719949585.davem@davemloft.net>
	 <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
	 <20160401.221632.846129753053296932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, aduyck@mirantis.com,
	herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33722 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755948AbcDBCVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:21:52 -0400
Received: by mail-yw0-f171.google.com with SMTP id t10so6966520ywa.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 19:21:51 -0700 (PDT)
In-Reply-To: <20160401.221632.846129753053296932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 22:16 -0400, David Miller wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 1 Apr 2016 12:58:41 -0700
> 
> > RFC 6864 is pretty explicit about this, IPv4 ID used only for
> > fragmentation.  https://tools.ietf.org/html/rfc6864#section-4.1
> > 
> > The goal with this change is to try and keep most of the existing
> > behavior in tact without violating this rule?  I would think the
> > sequence number should give you the ability to infer a drop in the
> > case of TCP.  In the case of UDP tunnels we are now getting a bit more
> > data since we were ignoring the outer IP header ID before.
> 
> When retransmits happen, the sequence numbers are the same.  But you
> can then use the IP ID to see exactly what happened.  You can even
> tell if multiple retransmits got reordered.
> 
> Eric's use case is extremely useful, and flat out eliminates ambiguity
> when analyzing TCP traces.

Yes, our team (including Van Jacobson ;) ) would be sad to not have
sequential IP ID (but then we don't have them for IPv6 ;) )

Since the cost of generating them is pretty small (inet->inet_id
counter), we probably should keep them in linux. Their usage will phase
out as IPv6 wins the Internet war...
