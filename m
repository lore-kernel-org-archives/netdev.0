From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 22 Apr 2009 16:33:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0904221628330.10428@wlug.westbo.se>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
 <87eivnpqde.fsf@basil.nowhere.org> <65634d660904202026r7d73f810s700bacb8756e0967@mail.gmail.com>
 <49ED967B.4070105@cosmosbay.com> <20090421084636.198b181e@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Tom Herbert <therbert@google.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host91-201.netintact.se ([194.153.91.201]:52003 "EHLO
	wlug.westbo.se" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbZDVOdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 10:33:11 -0400
In-Reply-To: <20090421084636.198b181e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009, Stephen Hemminger wrote:

> I would like to see some way to have multiple CPU's pulling packets and adapting
> the number of CPU's being used based on load. Basically, turn all device is into
> receive multiqueue. The mapping could be adjusted by user level (see irqbalancer).

I've been toying with the irqbalancer idea as well.
Set the number of software "queues" high and have a mapping table of 
queue->cpu and then let irqbalanced which has knowledge of cpu cache 
hirarchy etc balance the load by changing the mapping table as it sees 
fit.

This would make it fairly fine grained so that it could work reasonably 
well even if you have very few but very performance demanding clients.
Having "collisions" in the queues in that situation isn't very good.

/Martin
