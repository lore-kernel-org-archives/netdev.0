From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Mon, 07 Jul 2008 14:17:56 +0200
Message-ID: <48720974.5090907@trash.net>
References: <20080616221525.GG27971@xi.wantstofly.org> <4857AB84.2090409@trash.net> <486FBE5D.1020807@trash.net> <20080707120541.GB2026@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58732 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbYGGMR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:17:59 -0400
In-Reply-To: <20080707120541.GB2026@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Sat, Jul 05, 2008 at 08:33:01PM +0200, Patrick McHardy wrote:
> 
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 037929f..d0157d4 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -188,8 +188,7 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
>>  	veth->h_vlan_TCI = htons(tag);
>>  
>>  	skb->protocol = htons(ETH_P_8021Q);
>> -	skb->mac_header -= VLAN_HLEN;
>> -	skb->network_header -= VLAN_HLEN;
> 
> This works -- I can now just calculate
> '(void *)skb->data - (void *)ip_hdr(skb)' to find out how many bytes
> there are in the virtual ethernet header (i.e. ethernet header plus
> VLAN tag(s)) and program the TX descriptor accordingly.  (But in the
> VLAN case, I only ever get packets that have already been checksummed
> -- but that's another issue.)
> 
> 
>> +	skb_reset_mac_header(skb);
> 
> I'm not sure whether there is much point to doing this.  With this
> change, VLAN-tagged packets are given to ->hard_start_xmit() with
> ethhdr pointing to skb->data instead of NULL, but non-VLAN-tagged
> packets are still passed in with ethhdr being NULL.

You're right, its not strictly necessary. I'll remove that part
again.
