From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH bridge 3/5] bridge: Add vlan id to multicast groups
Date: Thu, 30 Aug 2012 05:55:33 -0700
Message-ID: <1346331333.2586.6.camel@edumazet-glaptop>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	 <1345750195-31598-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43625 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab2H3Mzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 08:55:35 -0400
Received: by dady13 with SMTP id y13so1196515dad.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 05:55:35 -0700 (PDT)
In-Reply-To: <1345750195-31598-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 15:29 -0400, Vlad Yasevich wrote:
> Add vlan_id to multicasts groups so that we know which vlan each group belongs
> to and can correctly forward to appropriate vlan.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---

>  #if IS_ENABLED(CONFIG_IPV6)
>  static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
> -				const struct in6_addr *ip)
> +				const struct in6_addr *ip,
> +				__u16 vid)
>  {
> -	return jhash2((__force u32 *)ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
> +	u32 addr = *(__force u32 *)ip->s6_addr32;
> +	return jhash_2words(addr, vid, mdb->secret) & (mdb->max - 1);
>  }
>  #endif

It seems to me this is wrong.

Hashing only the first 32bits of the IPv6 address is not enough.

We know have ipv6_addr_hash()
