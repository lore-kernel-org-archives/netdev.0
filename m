From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 09:51:31 +0200
Message-ID: <20110612095131.6d924082@konijn>
References: <20110611215919.5fc29c27@konijn>
	<1307850224.22348.626.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr8.xs4all.nl ([194.109.24.28]:1687 "EHLO
	smtp-vbr8.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab1FLHvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 03:51:46 -0400
In-Reply-To: <1307850224.22348.626.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2011-06-12, Ben Hutchings <bhutchings@solarflare.com> wrote:
> LRO implementations (and GRO) are expected to put the actual segment
> size in skb_shared_info(skb)->gso_size on the aggregated skb.  TCP
> will then use that rather than the aggregated payload size when
> deciding whether to defer an ACK.

Thanks. I see that indeed gso_size is being used for MSS calculations
instead of the total GRO size.

However, I'm not sure that this completely answers my question.
I am not so much concerned about quick ACK vs delayed ACK.
Instead, I'm looking at the total number of ACKs transmitted.
The sender depends on the _number_ of ACKs to update its congestion
window.

As far as I can see, current code will send just one ACK per coalesced
GRO bundle, while the sender expects one ACK per two segments.

Thanks,
Joris.
