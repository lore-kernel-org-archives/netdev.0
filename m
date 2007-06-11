From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 17:35:18 -0400
Message-ID: <1181597718.4071.12.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>
	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>
	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>
	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>
	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:39658 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbXFKVfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 17:35:24 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1415584nzf
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:35:21 -0700 (PDT)
In-Reply-To: <466D6DF6.9060300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 17:44 +0200, Patrick McHardy wrote:
> jamal wrote:
[..]
> > - let the driver shutdown whenever a ring is full. Remember which ring X
> > shut it down.
> > - when you get a tx interupt or prun tx descriptors, if a ring <= X has
> > transmitted a packet (or threshold of packets), then wake up the driver
> > (i.e open up). 
> 
> 
> At this point the qdisc might send new packets. What do you do when a
> packet for a full ring arrives?
> 

Hrm... ok, is this a trick question or i am missing the obvious?;->
What is wrong with what any driver would do today - which is:
netif_stop and return BUSY; core requeues the packet?

> I see three choices:
> 
> - drop it, even though its still within the qdiscs configured limits
> - requeue it, which does not work because the qdisc is still active
>   and might just hand you the same packet over and over again in a
>   busy loop, until the ring has more room (which has the same worst
>   case, just that we're sitting in a busy loop now).
> - requeue and stop the queue: we're back to where we started since
>   now higher priority packets will not get passed to the driver.

Refer to choice #4 above. 

The patches are trivial - really; as soon as Peter posts the e1000
change for his version i should be able to cutnpaste and produce one
that will work with what i am saying.
I am going to try my best to do that this week - i am going to be a
little busy and have a few outstanding items (like the pktgen thing)
that i want to get out of the way...

cheers,
jamal

