From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Fri, 8 Mar 2013 16:23:38 +0100
Message-ID: <20130308152338.GA1520@minipsycho.orion>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
 <1360687182.6884.5.camel@edumazet-glaptop>
 <20130217161803.GB1931@minipsycho.orion>
 <1361123663.19353.94.camel@edumazet-glaptop>
 <20130218095837.GA1566@minipsycho.orion>
 <1361290502.19353.136.camel@edumazet-glaptop>
 <20130219164626.GC1506@minipsycho.orion>
 <1361293287.19353.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:54923 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757954Ab3CHPXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 10:23:43 -0500
Received: by mail-ea0-f173.google.com with SMTP id h14so246197eak.32
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 07:23:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1361293287.19353.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 19, 2013 at 06:01:27PM CET, eric.dumazet@gmail.com wrote:
>On Tue, 2013-02-19 at 17:46 +0100, Jiri Pirko wrote:
>
>> About the gso_segment, do you see any cons doing that on enqueue path
>> rather than dequeue?
>> 
>
>It would be fine, and could be done in core stack instead of qdisc.
>

So you mean for example in tcp code? the maximum possible size would be
propagated from set qdiscs up to the tcp code?

I'm not sure how exactly do that.

>netif_skb_features() for example has the following (incomplete) check
>
>if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
>    features &= ~NETIF_F_GSO_MASK;

Why this is incomplete?

>
>We do have a dev->gso_max_size, but its currently used in TCP stack to
>size the skbs built in tcp_sendmsg().

Where exactly in tcp_sendmsg() this is? I found dev->gso_max_size is copied to
sk_gso_max_size in tcp_v4_connect->sk_setup_caps.

>
>In a forwarding workload, it seems we dont use/check gso_max_size.

Yep, that would require to do the segmentation in enqueue anyway. Maybe
I can implement segmentation in enqueue path first and provide tcp
optimalization after that. What do you think?


Thanks!

Jiri
