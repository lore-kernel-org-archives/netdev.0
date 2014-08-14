From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2] tcp: don't allow syn packets without timestamps
 to pass tcp_tw_recycle logic
Date: Thu, 14 Aug 2014 14:40:55 -0700 (PDT)
Message-ID: <20140814.144055.2100860870774307871.davem@redhat.com>
References: <6c91df2ee8f92c4687c98342d5dde52bbc3c5fe8.1408046709.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fw@strlen.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932068AbaHNVlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:41:07 -0400
In-Reply-To: <6c91df2ee8f92c4687c98342d5dde52bbc3c5fe8.1408046709.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 14 Aug 2014 22:06:12 +0200

> tcp_tw_recycle heavily relies on tcp timestamps to build a per-host
> ordering of incoming connections and teardowns without the need to
> hold state on a specific quadruple for TCP_TIMEWAIT_LEN, but only for
> the last measured RTO. To do so, we keep the last seen timestamp in a
> per-host indexed data structure and verify if the incoming timestamp
> in a connection request is strictly greater than the saved one during
> last connection teardown. Thus we can verify later on that no old data
> packets will be accepted by the new connection.
> 
> During moving a socket to time-wait state we already verify if timestamps
> where seen on a connection. Only if that was the case we let the
> time-wait socket expire after the RTO, otherwise normal TCP_TIMEWAIT_LEN
> will be used. But we don't verify this on incoming SYN packets. If a
> connection teardown was less than TCP_PAWS_MSL seconds in the past we
> cannot guarantee to not accept data packets from an old connection if
> no timestamps are present. We should drop this SYN packet. This patch
> closes this loophole.
> 
> Please note, this patch does not make tcp_tw_recycle in any way more
> usable but only adds another safety check:
> Sporadic drops of SYN packets because of reordering in the network or
> in the socket backlog queues can happen. Users behing NAT trying to
> connect to a tcp_tw_recycle enabled server can get caught in blackholes
> and their connection requests may regullary get dropped because hosts
> behind an address translator don't have synchronized tcp timestamp clocks.
> tcp_tw_recycle cannot work if peers don't have tcp timestamps enabled.
> 
> In general, use of tcp_tw_recycle is disadvised.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
