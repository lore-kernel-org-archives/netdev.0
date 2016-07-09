From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Sat, 9 Jul 2016 11:35:03 -0400
Message-ID: <f73e3794-1ba7-ffc5-a742-e4dc9b6dab7f@stressinduktion.org>
References: <cover.1467895623.git.pabeni@redhat.com>
 <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley>
 <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
 <CAKgT0UcHB9W3S6W_Di24QtSicNtru3sO4LRuvMAogqKKn1d+ww@mail.gmail.com>
 <643a68e2-b3d8-a21b-79ff-9ba7b7c9f418@stressinduktion.org>
 <CAKgT0UciEg0u3aqzQdEuLpaHAK2mXTwf9ng--84m7jL1wdsjnQ@mail.gmail.com>
 <1dc81b88-47c9-4274-6275-490b16526d4a@stressinduktion.org>
 <20160709181816.1f601239@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:39729 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751513AbcGIPfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 11:35:06 -0400
In-Reply-To: <20160709181816.1f601239@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.07.2016 11:18, Shmulik Ladkani wrote:
> On Fri, 8 Jul 2016 19:04:27 -0400 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>>>> I really do wonder if GRO on top of fragmentation does have any effect.
>>>> Would be great if someone has data for that already?  
>>>
>>> I think that logic is kind of backwards.  It is already there.
>>> Instead of asking people to prove that this change is invalid the onus
>>> should be on the submitter to prove the change causes no harm.  
>>
>> Of course, sorry, I didn't want to make the impression others should do
>> that. I asked because Shmulik made the impression on me he had
>> experience with GRO+fragmentation on vxlan and/or geneve and could
>> provide some data, maybe even just anecdotal.
> 
> Few anecdotal updates.
> 
> I don't have ready-made data as the systems are not using this exact
> kind of of setup.
> 
> However, by performing some quick experimentations, it reveals that GRO
> on top of the tunnels, where tunnel datagrams are fragmented, has some
> effect. The packets indeed get aggregated, although not aggresively as
> in the non-fragmented case.
> 
> Whether the effect is significant depends on the system.
> 
> In a system that is very sensitive to non-aggregated skbs (due to a cpu
> bottleneck during further processing of the decapsulated packets), the
> effect of aggregation is indeed significant.

Cool, thanks. I thought it wouldn't happen because of the packet pacing.
We will also do some more tests ourselves. Maybe it is time to add
fragmentation support to inet_gro_receive to handle those cases much
more easily without going through fragmentation engine at all, would
probably speed up your usage significantly?

Talking about ip fragmentation in general, are you end-host or
mid-router fragmented? Do you know if there are different
characteristics if linux fragments vs. some kind of hw-router in the
middle (do fragments get paced?).

Thanks,
Hannes
