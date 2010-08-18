From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 07:02:44 -0400
Message-ID: <1282129364.23601.17.camel@bigi>
References: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45808 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab0HRLCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 07:02:48 -0400
Received: by qyk9 with SMTP id 9so862685qyk.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 04:02:47 -0700 (PDT)
In-Reply-To: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 13:05 +0800, Changli Gao wrote:

> -static int has_ports(u8 protocol)
> -{
> -	switch (protocol) {
> -	case IPPROTO_TCP:
> -	case IPPROTO_UDP:
> -	case IPPROTO_UDPLITE:
> -	case IPPROTO_SCTP:
> -	case IPPROTO_DCCP:
> -	case IPPROTO_ESP:
> -		return 1;
> -	default:
> -		return 0;
> -	}
> -}
> -
>  static u32 flow_get_proto_src(struct sk_buff *skb)
>  {
>  	switch (skb->protocol) {
>  	case htons(ETH_P_IP): {
>  		struct iphdr *iph;
> +		int poff;
>  
>  		if (!pskb_network_may_pull(skb, sizeof(*iph)))
>  			break;
>  		iph = ip_hdr(skb);
> -		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
> -		    has_ports(iph->protocol) &&
> -		    pskb_network_may_pull(skb, iph->ihl * 4 + 2))
> -			return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
> +		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
> +			break;
> +		poff = proto_ports_offset(iph->protocol);
> +		if (poff >= 0 &&


I dont think this maintains the same semantic. Ex: In the original code
AH returns 0. In your case it returns 4 and passes the above test.
Same with the other spot.

cheers,
jamal

