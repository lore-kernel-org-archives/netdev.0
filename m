From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Tue, 23 Jul 2013 00:06:31 +0200
Message-ID: <DUB107-W43809186CF94F192981E9FED6E0@phx.gbl>
References: <51ED998D.7000300@youview.com>,<20130722211855.GL19643@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>,
	William Manley <william.manley@youview.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc3-s24.dub0.hotmail.com ([157.55.2.33]:43992 "EHLO
	dub0-omc3-s24.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab3GVWMo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 18:12:44 -0400
In-Reply-To: <20130722211855.GL19643@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Date: Mon, 22 Jul 2013 17:18:55 -0400
>> I would guess that this 10s has come from IGMPv2 RFC2236, which was
>> reduced to 1s in IGMPv3 RFC3376.
>
> Reducing the timeout does not solve the problem you are encountering, as
> any packet loss will still result in a 1 second delay.

Packet loss will always result in a delay and I think William is well aware
of that.

off-topic: 1 second is not a problem in IPTV, 10 seconds are ([1]).



> The correct approach is to queue the IGMP multicast join with a higher
> priority than other traffic in the system so that the requests are not
> lost due to congestion of a single queue.

While this certainly makes sense, congestion is not the only reason for
packet loss. There is no way to fix packet loss in lower network layers,
like ADSL, satellite links or IPoAC.

Improving retransmission by making it more predictable, bringing it closer
to RFC proposals and real life problems makes a lot of sense, imho. This
includes setting TC_PRIO_CONTROL, but I'm not sure it will fix Williams use
case.


lukas

[1] http://en.wikipedia.org/wiki/Zap_time 		 	   		  