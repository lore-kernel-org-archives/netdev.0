From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 13:17:24 -0700
Message-ID: <4C3E1B54.40604@hp.com>
References: <4C3D94E3.9080103@wildgooses.com>	<4C3DD5EB.9070908@tmr.com>	<20100714.111553.104052157.davem@davemloft.net> <4C3E0684.5060409@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ed W <lists@wildgooses.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:33914 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757364Ab0GNUR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:17:29 -0400
In-Reply-To: <4C3E0684.5060409@wildgooses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ed W wrote:

> 
> Just checking the basics here because I don't think this is a bug so 
> much as a, less common installation that differs from the "normal" case.
> 
> - When we create a tcp connection we always start with tcp slow start
> - This sets the congestion window to effectively 4 packets?
> - This applies in both directions?

Any TCP sender in some degree of compliance with the RFCs on the topic will 
employ slow-start.

Linux adds the auto-tuning of the receiver's advertised window.  It will start 
at a small size, and then grow it as it sees fit.

> - Remote sender responds to my hypothetical http request with the first 
> 4 packets of data
> - We need to wait one RTT for the ack to come back and now we can send 
> the next 8 packets,
> - Wait for the next ack and at 16 packets we are now moving at a 
> sensible fraction of the bandwidth delay product?

There may be some wrinkles depending on how many ACKs the reciever generates 
(LRO being enabled and such) and how the ACKs get counted.

> So just to be clear:
> - We don't seem to have any user-space tuning knobs to influence this 
> right now?
> - In this age of short attention spans, a couple of extra seconds 
> between clicking something and it responding is worth optimising (IMHO)

There is an effort under way, lead by some folks at Google and including some 
others, to get the RFC's enhanced in support of the concept of larger initial 
congestion windows.  Some of the discussion may be in the "tcpm" mailing list 
(assuming I've not gotten my mailing lists confused).  There may be some 
previous discussion of that work in the netdev archives as well.

rick jones

> - I think I need to take this to netdev, but anyone else with any ideas 
> happy to hear them?
> 
> Thanks
> 
> Ed W
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

