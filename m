From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 09:21:40 -0700
Message-ID: <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
References: <cover.1467895623.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33840 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755871AbcGHQVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 12:21:41 -0400
Received: by mail-io0-f175.google.com with SMTP id i186so46077184iof.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 09:21:41 -0700 (PDT)
In-Reply-To: <cover.1467895623.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
> at the ingress device level. Currently both the geneve and the vxlan drivers
> implement an additional GRO aggregation point via gro_cells.
> The latter takes effect for tunnels using zero checksum udp packets, which are
> currently explicitly not aggregated by the udp offload layer.
>
> This patch series adapts the udp tunnel offload to process also zero checksum
> udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
> performed at the ingress device level.
>
> Then the gro_cells hooks, in both vxlan and geneve driver are removed.

I think removing the gro_cells hooks may be taking things one step too far.

I get that there is an impression that it is redundant but there are a
number of paths that could lead to VXLAN or GENEVE frames being
received that are not aggregated via GRO.  My concern here is that you
are optimizing for one specific use case while at the same time
possibly negatively impacting other use cases.  It would be useful to
provide some data on what the advantages and disadvantages are
expected to be.

- Alex
