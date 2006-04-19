From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RESEND][PATCH] ebtables: clean up vmalloc usage in
 net/bridge/netfilter/ebtables.c
Date: Wed, 19 Apr 2006 15:41:26 -0700 (PDT)
Message-ID: <20060419.154126.64036253.davem@davemloft.net>
References: <20060419065025.GE17192@random.pao.digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, bdschuym@pandora.be, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61922
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751291AbWDSWlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 18:41:25 -0400
To: jchandra@digeo.com
In-Reply-To: <20060419065025.GE17192@random.pao.digeo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


An earlier variant of your patch was applied already, included below.
You'll need to submit the newer parts relative to the current tree.

diff-tree 7ad4d2f6901437ba4717a26d395a73ea362d25c6 (from b8282dcf0417bbc8a0786c129fdff9cc768f8f3c)
Author: Jayachandran C <c.jayachandran@gmail.com>
Date:   Tue Apr 11 17:25:38 2006 -0700

    [BRIDGE] ebtables: fix allocation in net/bridge/netfilter/ebtables.c
    
    Allocate an array of 'struct ebt_chainstack *', the current code allocates
    array of 'struct ebt_chainstack'.
    
    akpm: converted to use the
    
    	foo = alloc(sizeof(*foo))
    
    form.  Which would have prevented this from happening in the first place.
    
    akpm: also removed unneeded typecast.
    
    akpm: what on earth is this code doing anyway?  cpu_possible_map can be
    sparse..
    
    Signed-off-by: Jayachandran C. <c.jayachandran@gmail.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 66bd932..84b9af7 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -824,9 +824,9 @@ static int translate_table(struct ebt_re
 	if (udc_cnt) {
 		/* this will get free'd in do_replace()/ebt_register_table()
 		   if an error occurs */
-		newinfo->chainstack = (struct ebt_chainstack **)
-		   vmalloc((highest_possible_processor_id()+1) 
-				   		* sizeof(struct ebt_chainstack));
+		newinfo->chainstack =
+			vmalloc((highest_possible_processor_id()+1)
+				   	* sizeof(*(newinfo->chainstack)));
 		if (!newinfo->chainstack)
 			return -ENOMEM;
 		for_each_possible_cpu(i) {
