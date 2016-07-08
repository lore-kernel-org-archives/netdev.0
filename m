From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Sat, 9 Jul 2016 00:19:08 +0300
Message-ID: <20160709001908.1ff9f4ea@halley>
References: <cover.1467895623.git.pabeni@redhat.com>
	<CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
	<20160708231734.6258c00b@halley>
	<e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35905 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756224AbcGHVTP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:19:15 -0400
Received: by mail-wm0-f48.google.com with SMTP id f126so25529583wma.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 14:19:14 -0700 (PDT)
In-Reply-To: <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jul 2016 16:57:10 -0400 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On 08.07.2016 16:17, Shmulik Ladkani wrote:
> > On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:  
> >> I get that there is an impression that it is redundant but there are a
> >> number of paths that could lead to VXLAN or GENEVE frames being
> >> received that are not aggregated via GRO.  
> > 
> > There's the case where the vxlan/geneve datagrams get IP fragmented, and
> > IP frags are not GROed.
> > GRO aggregation at the vxlan/geneve level is beneficial for this case.  
> 
> Isn't this a misconfiguration? TCP should not fragment at all, not even
> in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
> anyway.

It's not an ideal configuration, but it is a valid one.

Imagine TCP within vxlan/geneve, that gets properly segmented and
encapsulated.

The vxlan/geneve datagrams go out the wire, and these can occasionally
be fragmented on the way (e.g. when we can't control the MTUs along the
path, or if unable to use PMTUD for whatever reason).

At the receiving vxlan/geneve termination, these IP frags are not GROed.

Instead they get reassembled by the IP stack, then handed to UDP and to
the vxlan/geneve drivers.

>From that point, GROing at the vxlan/geneve device, which aggregates
the TCP segments into a TCP super-packet still make sense and has
benefits.

Regards,
Shmulik
