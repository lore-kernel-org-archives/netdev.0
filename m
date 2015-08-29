From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Fri, 28 Aug 2015 22:14:04 -0700 (PDT)
Message-ID: <20150828.221404.100480720904987645.davem@davemloft.net>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbbH2FOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:14:04 -0400
In-Reply-To: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 28 Aug 2015 17:34:20 -0700

> Currently the VRF driver registers an Rx handler for enslaved devices.
> The handler switches the skb->dev to the VRF device and sends it back for
> another pass. While this works fine a side effect is that it bypasses
> netfilter with the skb set to the original device.
> 
> Looking at how to provide that feature a few options come to mind:
> 1. Have the rx handler in the VRF driver duplicate some of the processing
>    of ip_rcv up to the NF_HOOK and then switch the skb->dev to vrf device.
> 
> 2. Run NF_HOOK in ip_rcv twice -- once with orig_dev and then again for dev.
> 
> 3. Introduce an L3 rx-handler that provides the option of hooking packets
>    at L3 rather than the current backlog loop.
> 
> This RFC looks at option 3. I wanted to get opinions on the approach
> versus other options.

No way, this is not going to pass.

I've been playing my trumpet supporting this work, but as time wears
on and we are adding more and more hacks all over the tree I like this
VRF infrastructure less and less.

If you cannot figure out the right clean abstraction for what you want
to do, SIT AND WAIT.  Think about it for a while instead of posting
"yet another hook" type changes like this.

Thanks.
