From: David Miller <davem@davemloft.net>
Subject: Re: IPX changes introduce warning.
Date: Wed, 09 Aug 2006 17:36:48 -0700 (PDT)
Message-ID: <20060809.173648.77057307.davem@davemloft.net>
References: <20060809234417.GA23634@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52875
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932448AbWHJAhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 20:37:01 -0400
To: davej@redhat.com
In-Reply-To: <20060809234417.GA23634@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 9 Aug 2006 19:44:17 -0400

> We've just added an implicit declaration in the latest tree..
> 
> net/ipx/af_ipx.c: In function 'ipx_rcv':
> net/ipx/af_ipx.c:1648: error: implicit declaration of function 'ipxhdr'
> 
> (Yes, my builds fail on -Werror-implicit, so that things like this get caught early)
> 
> Probably something simple like a missing #include, but I'm heading out
> the door right now :)  I'll poke at it later if no-one has beaten me to it.

I could have sworn this compiled in my tree, sorry.

Fix below.  Greg, I'll queue this up to you in a GIT tree along
with another fix later tonight.

Thanks Dave.

commit fff642570dc47ab76491fe81ee6599269c4eb13e
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Aug 9 17:36:15 2006 -0700

    [IPX]: Fix typo, ipxhdr() --> ipx_hdr()
    
    Noticed by Dave Jones.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 4019642..bef3f61 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1645,7 +1645,7 @@ static int ipx_rcv(struct sk_buff *skb, 
 	if (!pskb_may_pull(skb, sizeof(struct ipxhdr)))
 		goto drop;
 
-	ipx_pktsize = ntohs(ipxhdr(skb)->ipx_pktsize);
+	ipx_pktsize = ntohs(ipx_hdr(skb)->ipx_pktsize);
 	
 	/* Too small or invalid header? */
 	if (ipx_pktsize < sizeof(struct ipxhdr) ||
