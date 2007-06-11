From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 10:40:15 -0400
Message-ID: <1181572815.4077.13.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>
	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:11909 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbXFKOkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 10:40:19 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1471156wxc
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 07:40:18 -0700 (PDT)
In-Reply-To: <466D5623.7060708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 16:03 +0200, Patrick McHardy wrote:
> jamal wrote:

> > Sure - but what is wrong with that?
> 
> Nothing, this was just to illustrate why I disagree with the assumption
> that the packet has hit the wire. 

fair enough.

> On second thought I do agree with your
> assumption for the single HW queue case, at the point we hand the packet
> to the HW the packet order is determined and is unchangeable. But this
> is not the case if the hardware includes its own scheduler. The qdisc
> is simply not fully in charge anymore.

 i am making the case that it does not affect the overall results
as long as you use the same parameterization on qdisc and hardware.
If in fact the qdisc high prio packets made it to the driver before
the they make it out onto the wire, it is probably a good thing
that the hardware scheduler starves the low prio packets.

> Read again what I wrote about the n > 2 case. Low priority queues might
> starve high priority queues when using a single queue state for a
> maximum of the time it takes to service n - 2 queues with max_qlen - 1
> packets queued plus the time for a single packet. Thats assuming the
> worst case of n - 2 queues with max_qlen - 1 packets and the lowest
> priority queue full, so the queue is stopped until we can send at
> least one lowest priority packet, which requires to fully service
> all higher priority queues previously.

I didnt quiet follow the above - I will try retrieving reading your
other email to see if i can make sense of it. 

> Your basic assumption seems to be that the qdisc is still in charge
> of when packets get sent. This isn't the case if there is another
> scheduler after the qdisc and there is contention in the second
> queue.

My basic assumption is if you use the same scheduler in both the
hardware and qdisc, configured the same same number of queues and
mapped the same priorities then you dont need to make any changes
to the qdisc code. If i have a series of routers through which a packet
traveses to its destination with the same qos parameters i also achieve
the same results.

cheers,
jamal

