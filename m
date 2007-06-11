From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 09:29:58 -0400
Message-ID: <1181568598.4043.250.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:33121 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbXFKNaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 09:30:04 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1450553wxc
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 06:30:02 -0700 (PDT)
In-Reply-To: <466D480F.6090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 15:03 +0200, Patrick McHardy wrote:
> jamal wrote:

> Well, its not.

I dont wanna go into those old style debates again; so lets drop this
point. 

> > Take a step back:
> > When you put a packet on the DMA ring, are you ever going to take it
> > away at some point before it goes to the wire? 
> 
> 
> No, 
> but its nevertheless not on the wire yet and the HW scheduler
> controls when it will get there. 
>
> It might in theory even never get
> there if higher priority queues are continously active.

Sure - but what is wrong with that? 
What would be wrong is in the case of contention for a resource like a
wire between a less important packet and a more important packet, the
more important packet gets favored.
Nothing like that ever happens in what i described.
Remember there is no issue if there is no congestion or contention for
local resources.

> > And if there is contention, the qdisc scheduler will do the right thing.
> 
> 
> That ignores a few points that were raised in this thread,
> 
> - you can treat each HW queue as an indivdual network device

You can treat a pair of tx/rx as a netdev. In which case none of this is
important. You instantiate a different netdev and it only holds the
appropriate locks.

> - you can avoid synchronizing on a single queue lock for
>   multiple TX queues

Unneeded if you do what i described. Zero changes to the qdisc code.

> - it is desirable to keep all queues full

It is desirable to keep resources fully utilized. Sometimes that is
achieved by keeping _all_ queues full. If i fill up a single queue full
and transmit at wire rate, there is no issue.

cheers,
jamal

