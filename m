From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Missing INET6_PROTO_FINAL in l2tp_ip6_protocol?
Date: Sat, 21 May 2016 17:55:59 +0200
Message-ID: <9bd1a821-17ea-778a-b0c7-4e9e35f9fcc1@stressinduktion.org>
References: <20160521155003.1410579f@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:45313 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752311AbcEUP4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 11:56:03 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1757020BA6
	for <netdev@vger.kernel.org>; Sat, 21 May 2016 11:56:02 -0400 (EDT)
In-Reply-To: <20160521155003.1410579f@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2016 14:50, Shmulik Ladkani wrote:
> Hi,
> 
> inet6_protocol's INET6_PROTO_FINAL flag denotes handler is expected not
> to request resubmission for local delivery.
> 
> For an INET6_PROTO_FINAL handler, the following actions gets executed
> prior delivery, in ip6_input_finish:
> 
> 			nf_reset(skb);
> 
> 			skb_postpull_rcsum(skb, skb_network_header(skb),
> 					   skb_network_header_len(skb));
> 
> For some reason, l2tp_ip6_protocol handler is NOT marked as
> INET6_PROTO_FINAL. Probably an oversight.
> 
> Since 'l2tp_ip6_recv' never results in a resubmission, the above actions
> are not applied to skbs passed to l2tp_ip6.
> 
> Any reason why l2tp_ip6_protocol should NOT be marked INET6_PROTO_FINAL?

I don't see any specific reason why it shouldn't be a INET6_PROTO_FINAL.
Anyway, receive path of L2TPv3 without UDP encapsulation doesn't deal
with checksums anyway, as far as I know.

> What's the consequences not executing the above actions for l2tp_ip6
> packets?

Probably not a whole lot in this case.

Bye,
Hannes
