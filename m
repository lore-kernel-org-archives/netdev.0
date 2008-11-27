From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 16:31:07 +0100
Message-ID: <1227799867.16263.517.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <492E3AAE.3000709@hartkopp.net> <1227780427.16263.468.camel@ecld0pohly>
	 <200811271602.16128.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbYK0PbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 10:31:12 -0500
In-Reply-To: <200811271602.16128.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-27 at 14:02 +0000, Octavian Purdila wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Thu, 27 Nov 2008 11:07:07 +0100
> > To summarize, I see the following options at this time:
> [snip]
> > My personal preference is, in this order: 3, 4, 2b (current patch,
> > but needs clean way to find network device), 1a.
> 
> I also vote for 3 (storing hw timestamps in the skb). 
> 
> Let me throw in another idea: when enabling hw timestamps could we allocate a 
> bigger skb and store the hw timestamp somewhere in the skb data buffer? 

How does the socket layer detect that the HW timestamp is available in
the larger skb data buffer, and where?

> We can then modify sock_recv_timestamp to call a new netdev method which 
> should return the hw timestamp. This should take care of RX hw timestamps.

Finding the netdev is non-trivial, see David's comment about the current
hacky approach via the route. Besides, if the time stamp is in the skb
data buffer, why is the netdev still needed? Do I miss something?

> There is still the problem of requesting TX timestamps per packets. At this 
> point it seems that on the TX path the tstamp field is not used, so we could 
> use that space. 

Agreed in general, but there was one corner case where the tstamp field
was set for looped multicast packets.

> Or, maybe we can use the same dynamic approach: can we modify the 
> hard_header_len after device registration (e.g. when TX timestamps are 
> enabled)?

I don't know.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

