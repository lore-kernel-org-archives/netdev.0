From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/3] bonding: modify the current and add
 new hash functions
Date: Thu, 03 Oct 2013 15:37:37 -0400 (EDT)
Message-ID: <20131003.153737.1071770171297832326.davem@davemloft.net>
References: <1380713966-3891-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3JCThj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:37:39 -0400
In-Reply-To: <1380713966-3891-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed,  2 Oct 2013 13:39:23 +0200

> This is a complete remake of my old patch that modified the bonding hash
> functions to use skb_flow_dissect which was suggested by Eric Dumazet.
> This time around I've left the old modes although using a new hash function
> again suggested by Eric, which is the same for all modes. The only
> difference is the way the headers are obtained. The old modes obtain them
> as before in order to address concerns about speed, but the 2 new ones use
> skb_flow_dissect. The unification of the hash function allows to remove a
> pointer from struct bonding and also a few extra functions that dealt with
> it. Two new functions are added which take care of the hashing based on
> bond->params.xmit_policy only:
> bond_xmit_hash() - global function, used by XOR and 3ad modes
> bond_flow_dissect() - used by bond_xmit_hash() to obtain the necessary
> headers and combine them according to bond->params.xmit_policy.
> Also factor out the ports extraction from skb_flow_dissect and add a new
> function - skb_flow_get_ports() which can be re-used.
> 
> v2: add the flow_dissector patch and use skb_flow_get_ports in patch 02
> v3: fix a bug in the flow_dissector patch that caused a different thoff
>     by modifying the thoff argument in skb_flow_get_ports directly, most
>     of the users already do it anyway.
>     Also add the necessary export symbol for skb_flow_get_ports.
> v4: integrate the thoff bug fix in patch 01
> v5: disintegrate the thoff bug fix and re-base on top of Eric's fix

Series applied, thanks al ot.
