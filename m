From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 16:57:10 -0400
Message-ID: <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
References: <cover.1467895623.git.pabeni@redhat.com>
 <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58815 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754606AbcGHU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 16:57:14 -0400
In-Reply-To: <20160708231734.6258c00b@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 16:17, Shmulik Ladkani wrote:
> On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>> With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
>>> at the ingress device level. Currently both the geneve and the vxlan drivers
>>> implement an additional GRO aggregation point via gro_cells.
>>> The latter takes effect for tunnels using zero checksum udp packets, which are
>>> currently explicitly not aggregated by the udp offload layer.
>>>
>>> This patch series adapts the udp tunnel offload to process also zero checksum
>>> udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
>>> performed at the ingress device level.
>>>
>>> Then the gro_cells hooks, in both vxlan and geneve driver are removed.  
>>
>> I think removing the gro_cells hooks may be taking things one step too far.
> 
> +1
> 
>> I get that there is an impression that it is redundant but there are a
>> number of paths that could lead to VXLAN or GENEVE frames being
>> received that are not aggregated via GRO.
> 
> There's the case where the vxlan/geneve datagrams get IP fragmented, and
> IP frags are not GROed.
> GRO aggregation at the vxlan/geneve level is beneficial for this case.

Isn't this a misconfiguration? TCP should not fragment at all, not even
in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
anyway.

Bye,
Hannes
