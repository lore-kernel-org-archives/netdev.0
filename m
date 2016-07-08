From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 23:17:34 +0300
Message-ID: <20160708231734.6258c00b@halley>
References: <cover.1467895623.git.pabeni@redhat.com>
	<CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33901 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbcGHURq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 16:17:46 -0400
Received: by mail-wm0-f52.google.com with SMTP id p190so4482820wmp.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 13:17:45 -0700 (PDT)
In-Reply-To: <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
> > at the ingress device level. Currently both the geneve and the vxlan drivers
> > implement an additional GRO aggregation point via gro_cells.
> > The latter takes effect for tunnels using zero checksum udp packets, which are
> > currently explicitly not aggregated by the udp offload layer.
> >
> > This patch series adapts the udp tunnel offload to process also zero checksum
> > udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
> > performed at the ingress device level.
> >
> > Then the gro_cells hooks, in both vxlan and geneve driver are removed.  
> 
> I think removing the gro_cells hooks may be taking things one step too far.

+1

> I get that there is an impression that it is redundant but there are a
> number of paths that could lead to VXLAN or GENEVE frames being
> received that are not aggregated via GRO.

There's the case where the vxlan/geneve datagrams get IP fragmented, and
IP frags are not GROed.
GRO aggregation at the vxlan/geneve level is beneficial for this case.

Regards,
Shmulik
