From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re : Bug in using inet_lookup ()
Date: Wed, 14 Nov 2007 16:31:18 +0300
Message-ID: <20071114133118.GA28232@2ka.mipt.ru>
References: <867900.85129.qm@web26107.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58303 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757075AbXKNNax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 08:30:53 -0500
Content-Disposition: inline
In-Reply-To: <867900.85129.qm@web26107.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 01:12:11PM +0000, Nj A (nj_a83@yahoo.fr) wrote:
> I suspected it could be that. However, can't see in ip_rcv the right portion that can help.
> Any further tip please?

It is ip_rcv_finish() called from ip_rcv():
	if (skb->dst == NULL) {
		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
					 skb->dev);
		if (unlikely(err)) {
			if (err == -EHOSTUNREACH)
				IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
			else if (err == -ENETUNREACH)
				IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
			goto drop;
		}
	}

So you will have to specify device, you got your skb via.
Actually it is not exactly needed in some cases, you will need interface
index (dev->ifindex). You can find socket by using that number instead
of dereferencing dst.

-- 
	Evgeniy Polyakov
