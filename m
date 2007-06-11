From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 08:23:31 -0400
Message-ID: <1181564611.4043.220.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:61685 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbXFKMXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:23:34 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1434075wxc
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 05:23:34 -0700 (PDT)
In-Reply-To: <466D38CF.9060709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 13:58 +0200, Patrick McHardy wrote:

> Thats not true. Assume PSL has lots of packets, PSH is empty. We
> fill the PHL queue until their is no room left, so the driver
> has to stop the queue. 

Sure. Packets stashed on the any DMA ring are considered "gone to the
wire". That is a very valid assumption to make.
 
> Now some PSH packets arrive, but the queue
> is stopped, no packets will be sent. 
> Now, you can argue that as
> soon as the first PHL packet is sent there is room for more and
> the queue will be activated again and we'll take PSH packets,

_exactly_ ;->

> so it doesn't matter because we can't send two packets at once
> anyway. Fine.

i can see your thought process building -
You are actually following what i am saying;->

>  Take three HW queues, prio 0-2. The prio 2 queue
> is entirely full, prio 1 has some packets queued and prio 0 is
> empty. Now, because prio 2 is completely full, the driver has to
> stop the queue. Before it can start it again it has to send all
> prio 1 packets and then at least one packet of prio 2. Until
> this happens, no packets can be queued to prio 0.

The assumption is packets gone to the DMA are gone to the wire, thats
it. 
If you have a strict prio scheduler, contention from the stack is only
valid if they both arrive at the same time.
If that happens then (assuming 0 is more important than 1 which is more
important than 2) then 0 always wins over 1 which wins over 2.
Same thing if you queue into hardware and the priorization is the same.

cheers,
jamal

