From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Tue, 23 Jul 2013 00:30:29 +0200
Message-ID: <20130722223029.GH6538@order.stressinduktion.org>
References: <20130722211855.GL19643@kvack.org> <DUB107-W43809186CF94F192981E9FED6E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	William Manley <william.manley@youview.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33065 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab3GVWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 18:30:30 -0400
Content-Disposition: inline
In-Reply-To: <DUB107-W43809186CF94F192981E9FED6E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 12:06:31AM +0200, Lukas Tribus wrote:
> > Date: Mon, 22 Jul 2013 17:18:55 -0400
> >> I would guess that this 10s has come from IGMPv2 RFC2236, which was
> >> reduced to 1s in IGMPv3 RFC3376.
> >
> > Reducing the timeout does not solve the problem you are encountering, as
> > any packet loss will still result in a 1 second delay.
> 
> Packet loss will always result in a delay and I think William is well aware
> of that.
> 
> off-topic: 1 second is not a problem in IPTV, 10 seconds are ([1]).
> 
> 
> 
> > The correct approach is to queue the IGMP multicast join with a higher
> > priority than other traffic in the system so that the requests are not
> > lost due to congestion of a single queue.
> 
> While this certainly makes sense, congestion is not the only reason for
> packet loss. There is no way to fix packet loss in lower network layers,
> like ADSL, satellite links or IPoAC.
> 
> Improving retransmission by making it more predictable, bringing it closer
> to RFC proposals and real life problems makes a lot of sense, imho. This
> includes setting TC_PRIO_CONTROL, but I'm not sure it will fix Williams use
> case.

Yes, it was merely meant as an RFC without the appropriate changes for IPv4
(I somehow missed this in the patch marker :| ).

Regarding the value of the IGMP unsolicited report interval, I would strictly
stick to the RFCs. So a change for IGMPv3 would be appropriate IMHO.

I would also suggest that posting patches would be favourable. I don't think
it should be too much work.

Thanks,

  Hannes
