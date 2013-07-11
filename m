From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 16:19:17 -0700
Message-ID: <CALnjE+oXbT+J01A-9GRxAAVuANaVA6ifF5_oc6ZSWRY2TTVUBw@mail.gmail.com>
References: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
	<CALnjE+p3tqNO9Fbn=+LLtL8VvfvSQyOLDZoFRvGFTXgJzHKqhQ@mail.gmail.com>
	<1373582702.4600.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, jesse@nicira.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:36365 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752039Ab3GKXTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 19:19:19 -0400
Received: by mail-qe0-f52.google.com with SMTP id i11so4760810qej.25
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 16:19:17 -0700 (PDT)
In-Reply-To: <1373582702.4600.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 3:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-07-11 at 15:24 -0700, Pravin Shelar wrote:
>> On Thu, Jul 11, 2013 at 1:12 PM, Alexander Duyck
>> <alexander.h.duyck@intel.com> wrote:
>> > This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
>> > packets are sent from the interface.
>> >
>> > In my case I was able to reproduce the issue by simply sending a ping of
>> > 1421 bytes with the gretap interface created on a device with a standard
>> > 1500 mtu.
>> >
>> > This fix is based on the fact that the tunnel mtu is already adjusted by
>> > dev->hard_header_len so it would make sense that any packets being compared
>> > against that mtu should also be adjusted by hard_header_len and the tunnel
>> > header instead of just the tunnel header.
>> >
>> we can simplify code by not doing dev->hard_header_len adjustment to tunnel-mtu.
>>
>> And right thing would be adjusting tunnel-mtu according to rt->dst.dev
>> header-len so that we get mtu for out going path.
>
> What's the mtu value we want to put in the ICMP message ?
>
>
I think it should be max payload that tunnel-device can take for that
route. Something like (route_mtu - (tunnel_header_len + iph_len +
route_dev->header_len))

gre is been using dev->hard_header_len rather than
rt_dev->hard_header_len for long time which does not look right.
