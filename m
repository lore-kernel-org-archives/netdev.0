From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 17:40:33 -0400
Message-ID: <b876be9e-3eca-5423-f99a-adc3d6a3ac99@stressinduktion.org>
References: <cover.1467895623.git.pabeni@redhat.com>
 <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley>
 <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
 <20160709001908.1ff9f4ea@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45767 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755636AbcGHVxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:53:01 -0400
In-Reply-To: <20160709001908.1ff9f4ea@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 17:19, Shmulik Ladkani wrote:
> On Fri, 8 Jul 2016 16:57:10 -0400 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>> On 08.07.2016 16:17, Shmulik Ladkani wrote:
>>> On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:  
>>>> I get that there is an impression that it is redundant but there are a
>>>> number of paths that could lead to VXLAN or GENEVE frames being
>>>> received that are not aggregated via GRO.  
>>>
>>> There's the case where the vxlan/geneve datagrams get IP fragmented, and
>>> IP frags are not GROed.
>>> GRO aggregation at the vxlan/geneve level is beneficial for this case.  
>>
>> Isn't this a misconfiguration? TCP should not fragment at all, not even
>> in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
>> anyway.
> 
> It's not an ideal configuration, but it is a valid one.
> 
> Imagine TCP within vxlan/geneve, that gets properly segmented and
> encapsulated.
> 
> The vxlan/geneve datagrams go out the wire, and these can occasionally
> be fragmented on the way (e.g. when we can't control the MTUs along the
> path, or if unable to use PMTUD for whatever reason).

PMTUD doesn't work with vxlan in most situations anyway. But you can
still control the mtu/mss with ip route and you don't need to modify the
mid-hosts.

> At the receiving vxlan/geneve termination, these IP frags are not GROed.
> 
> Instead they get reassembled by the IP stack, then handed to UDP and to
> the vxlan/geneve drivers.
> 
> From that point, GROing at the vxlan/geneve device, which aggregates
> the TCP segments into a TCP super-packet still make sense and has
> benefits.

Given the spreading with which those fragments will be send, I wonder if
the GRO ontop of the tunnels will really aggregate them?

Bye,
Hannes
