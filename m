From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Tue, 19 Feb 2013 09:01:27 -0800
Message-ID: <1361293287.19353.149.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
	 <1360687182.6884.5.camel@edumazet-glaptop>
	 <20130217161803.GB1931@minipsycho.orion>
	 <1361123663.19353.94.camel@edumazet-glaptop>
	 <20130218095837.GA1566@minipsycho.orion>
	 <1361290502.19353.136.camel@edumazet-glaptop>
	 <20130219164626.GC1506@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:64951 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932600Ab3BSRBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 12:01:32 -0500
Received: by mail-da0-f48.google.com with SMTP id v40so3074257dad.21
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 09:01:32 -0800 (PST)
In-Reply-To: <20130219164626.GC1506@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 17:46 +0100, Jiri Pirko wrote:

> About the gso_segment, do you see any cons doing that on enqueue path
> rather than dequeue?
> 

It would be fine, and could be done in core stack instead of qdisc.

netif_skb_features() for example has the following (incomplete) check

if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
    features &= ~NETIF_F_GSO_MASK;

We do have a dev->gso_max_size, but its currently used in TCP stack to
size the skbs built in tcp_sendmsg().

In a forwarding workload, it seems we dont use/check gso_max_size.
