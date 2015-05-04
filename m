From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] net: Eliminate calls to flow_dissector
 and introduce flow_keys_digest
Date: Mon, 04 May 2015 00:09:36 -0400 (EDT)
Message-ID: <20150504.000936.1447145169083187732.davem@davemloft.net>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbEDEJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:09:38 -0400
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 1 May 2015 11:30:11 -0700

> In this patch set we add skb_get_hash_perturb which gets the skbuff
> hash for a packet and perturbs it using a provided key and jhash1.
> This function is used in serveral qdiscs and eliminates many calls
> to flow_dissector and jhash3 to get a perturbed hash for a packet.
> 
> To handle the sch_choke issue (passes flow_keys in skbuff cb) we
> add flow_keys_digest which is a digest of a flow constructed
> from a flow_keys structure.
> 
> This is the second version of these patches I posted a while ago,
> and is prerequisite work to increasing the size of the flow_keys
> structure and hashing over it (full IPv6 address, flow label, VLAN ID,
> etc.).
> 
> Version 2:
> 
> - Add keyval parameter to __flow_hash_from_keys which allows caller to
>   set the initval for jhash
> - Perturb always does flow dissection and creates hash based on
>   input perturb value which acts as the keyval to __flow_hash_from_keys
> - Added a _flow_keys_digest_data which is used in make_flow_keys_digest.
>   This fills out the digest by populating individual fields instead
>   of copying the whole structure.

Series applied, thanks Tom.
