From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 20:05:38 +0200
Message-ID: <466D8EF2.50203@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290303AAE8@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48473 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbXFKSIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:08:11 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290303AAE8@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>I think we can reuse skb->priority. Assuming only real 
>>hardware devices use multiqueue support, there should be no user of
>>skb->priority after egress qdisc classification. The only reason
>>to preserve it in the qdisc layer is for software devices.
> 
> 
> That would be oustanding.
> 
> 
>>Grepping through drivers/net shows a few users, bot most seem 
>>to be using it on the RX path and some use it to store internal data.
> 
> 
> Thank you for hunting this down.  I will test on my little environment
> here to see if I run into any issues.


I think grepping will help more than testing :)

The only issue I can see is that packets going to a multiqueue device
that doesn't have a multiqueue aware qdisc attached will get a random
value. So you would have to conditionally reset it before ->enqueue.

Another question is what to do about other hard_start_xmit callers.
Independant of which field is used, should the classification that
may have happend on a different device be retained (TC actions again)?
