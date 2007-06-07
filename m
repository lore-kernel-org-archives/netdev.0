From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 08:03:29 -0700
Message-ID: <46681E41.6060700@intel.com>
References: <1181168020.4064.46.camel@localhost>	 <20070606.153530.48530367.davem@davemloft.net>	 <1181172766.4064.83.camel@localhost>	 <20070606.165215.38711917.davem@davemloft.net>	 <20070607004712.GE3304@havoc.gtf.org> <1181219380.4064.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16051 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758300AbXFGPDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:03:32 -0400
In-Reply-To: <1181219380.4064.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-06-06 at 20:47 -0400, Jeff Garzik wrote:
> 
>> 1) you need (a) well-designed hardware _and_ (b) a smart driver writer
>> to avoid bottlenecking on internal driver locks.  As you can see we have
>> both (a) and (b) for tg3 ;-)  
> 
> How about the following patch which fixes #b for e1000 ;->
> I think the e1000s challenges are related to the gazillion variations of
> boards they support and a little challenge of too many intel cooks.
> 
> Auke, why do you need the tx ring lock?

To prevent against multiple entries bumping head & tail at the same time as well 
as overwriting the same entries in the tx ring (contention for 
next_to_watch/next_to_clean)? It may be unlikely but ripping out the tx ring 
lock might not be a good idea, perhaps after we get rid of LLTX in e1000?

to be honest: I'm open for ideas and I'll give it a try, but stuff like this 
needs to go through some nasty stress testing (multiple clients, long time) 
before I will consider it seriously, but fortunately that's something I can do.

Auke
