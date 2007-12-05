From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: cassini driver skb->truesize bug
Date: Wed, 05 Dec 2007 11:23:46 +0100
Message-ID: <1196850226.9713.33.camel@bzorp.balabit>
References: <475561DB.7080404@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:38277 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbXLEKXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:23:49 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 50151C149C
	for <netdev@vger.kernel.org>; Wed,  5 Dec 2007 11:23:48 +0100 (CET)
In-Reply-To: <475561DB.7080404@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some more investigation revealed that the cassini driver leaks the data
portion of all RXed packets, this makes the driver completely unusable.

We've tested the following combinations:
 * 2.6.17 (patched, but no cassini related patches)
 * 2.6.22 Ubuntu Gutsy.

It still worked in 2.6.12 where we originally backported the driver from
2.6.14.

The sk_buff count in slabinfo stays normal, so the skbs are properly
freed. I'm suspicious about all this cas_page_t wrappers.

Is there a maintainer for this driver? All our previous questions went
unanswered.


On Tue, 2007-12-04 at 15:19 +0100, Laszlo Attila Toth wrote:
> Hello,
> 
> we got the following message:
> SKB BUG: Invalid truesize (376) len=514, sizeof(sk_buff)=248
> 
> It only occurs on larger traffic (at speed 100 Mbps: always), but  not 
> when downloading a small web page.
> 
> In cas_rx_process_pkt() the the skb's truesize is only set via skb_put()
> but it is not used if there are fragments, also skb->len is increased by
> the fragment's size, but the truesize member is unchanged. I compared it 
> to the implementation in e1000 where  all of the len, datalen and 
> trusize members are increased.
> 
> If I modify the code to add the fragment's size to the truesize member, 
> the driver allocates all available memory after a while.
> 
> Regards,
> Attila
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
-- 
Bazsi

