From: almaop@poczta.fm
Subject: Re: New filter 'flow' bug?
Date: 05 Nov 2008 14:29:05 +0100
Message-ID: <20081105132906.18BDA46CCF0@f46.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"almaop@poczta.fm" <almaop@poczta.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp239.poczta.interia.pl ([217.74.64.239]:30942 "EHLO
	smtp239.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbYKEN3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 08:29:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> almaop@poczta.fm wrote:
> >> almaop@poczta.fm wrote:
> >>>>> From: almaop@poczta.fm
> >>>>>> I'm not sure where is the bug - in the flow filter or in the sfq
> >>>> qdisc.
> >>>>
> >>>> Which SFQ qdisc is stalling?
> >>>>
> >>> Thanks for reply.
> >>> So I've done few tests. I've removed quantum 64 (it  was qdisc with
> >> small packets). It made no difference. It looks like the key is the
> first
> >> sfq qdisc (tc qdisc add dev $DEV parent 1:2 handle 2: sfq - in my
> example).
> >> When there is no traffic in this qdisc for about 45 seconds (shorter
> time
> >> when there is no traffic at all on the interface) - it stalls. Other
> qdiscs
> >> stall also. So there is no packet flow on that interface. Removing
> filters
> >> ('flow' filters) does'nt help. I have to remove (all) sfq qdiscs. And
> then
> >> the traffic is resumed.
> >>
> >> Please capture the output of "tc -s -d qdisc show dev <dev>" and
> >> "tc -s -d class show dev <dev>" immediately after it stalls.
> >> I'm interested in the amount of bytes/packets queued at the moment.
> >>
> > 
> > I've captured it eve
> > It looks like this:
> > Example 1:
> > 
> > ...
> 
> In both cases there are no packets queued, so its not the qdiscs
> which are stalling. My shot in the dark is  is that your classifier
> rules are incorrect and don't handle ARP packets.

I've removed 'tc qdisc add htb .... default x'
                                    ^^^^^^^^^^
And now it works, so you are right. Sorry for taking your time.
Regards.

Krzysiek

----------------------------------------------------------------------
Dzwon taniej na zagraniczne komorki!
Sprawdz >> http://link.interia.pl/f1f6a

