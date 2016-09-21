From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 08:39:55 +0200
Message-ID: <20160921083955.7cdba944@redhat.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <57E1CDE3.5030404@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        <tariqt@mellanox.com>, <bblanco@plumgrid.com>,
        <alexei.starovoitov@gmail.com>, <eric.dumazet@gmail.com>,
        brouer@redhat.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34444 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752931AbcIUGk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 02:40:29 -0400
In-Reply-To: <57E1CDE3.5030404@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 17:01:39 -0700 Alexei Starovoitov <ast@fb.com> wrote:

>  >  - Provides a more structured environment that is extensible to new
>  >    features while being mostly transparent to the drivers  
> 
> don't see that in these patches either.
> Things like packet size change (that we're working on) still
> has to be implemented for every driver.
> Existing XDP_TX, XDP_DROP have to be implemented per driver as well.
> 
> Also introduction of xdp.h breaks existing UAPI.
> That's not acceptable either.

This response piss me off!@@#$

We are the early stages of XDP development. Users cannot consider XDP a
stable UAPI yet.  I added a big fat warning to the docs here[1].

If you already consider this a stable API, then I will suggest that we
disable XDP or rip the hole thing out again!!! Create a separate tree
where we can cooperate on getting this right, before forcing this
upstream.  I have raise concern about this several times upstream, but
the patches got applied anyway, because you Alexei, promised this was
super extendable and we could still change the APIs later. Maybe you
tricked me?! I've started to look at the details, and I'm not happy with
the extensibility.  And I'm also not happy with Brenden's response to
my API concerns that this is just a "fire-and-forget" API.

Most importantly, the XDP interface for feature or capabilities
negotiation is missing.  Documented here[2].

I strongly believe the two actions XDP_DROP and XDP_TX should have been
express as two different capabilities, because XDP_TX requires more
changes to the device driver than a simple drop like XDP_DROP.

One can easily imagine (after the e1000 discussion) that an older
driver only want to implement the XDP_DROP facility. The reason is that
XDP_TX would requires changing too much driver code, which is a concern
for an old stable and time-proven driver.  Thus, the need for
negotiating features is already a practical problem!


[1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/implementation/userspace_api.html

Quote:
  "Warning: The userspace API specification should have to be defined
   properly before code was accepted upstream. Concerns have been raise
   about the current API upstream. Users should expect this first API
   attempt will need adjustments. This cannot be considered a stable API yet."

[2] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/design.html#capabilities-negotiation

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
