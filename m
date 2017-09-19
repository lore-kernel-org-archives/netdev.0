From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/14] net: Add a facility to support
 application defined GSO
Date: Mon, 18 Sep 2017 21:21:36 -0700 (PDT)
Message-ID: <20170918.212136.1947336336943040258.davem@davemloft.net>
References: <20170919003904.5124-1-tom@quantonium.net>
        <20170919003904.5124-12-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdISEVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 00:21:37 -0400
In-Reply-To: <20170919003904.5124-12-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 18 Sep 2017 17:39:01 -0700

> Allow applications or encapsulation protocols to register a GSO segment
> function to their specific protocol. To faciliate this I reserved the
> upper four bits in the gso_type to indicate the application specific GSO
> type. Zero in these bits indicates no application GSO, so there are
> fifteen instance that can be defined.
> 
> An application registers a a gso_segment using the skb_gso_app_register
> this takes a struct skb_gso_app that indicates a callback function as
> well as a set of GSO types for which at least one must be matched before
> calling he segment function. GSO returns one of the application GSO
> types described above (not a fixed value for the applications).
> Subsequently, when the application sends a GSO packet the application
> gso_type is set in the skb gso_type along with any other types.
> 
> skb_gso_app_segment is the function called from another GSO segment
> function to handle segmentation of the application or encapsulation
> protocol. This function includes check flags that provides context for
> the appropriate GSO instance to match. For instance, in order to handle
> a protocol encapsulated in UDP (GTP for instance) skb_gso_app_segment is
> call from udp_tunnel_segment and check flags would be
> SKB_GSO_UDP_TUNNEL_CSUM | SKB_GSO_UDP_TUNNEL.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>

What happens on cards that can offload existing arbitrary UDP tunnel
encapsulations?

Will something about the state of the GSO type bits you are adding
prevent that?  Or do we need to add some new checks somewhere?
