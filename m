From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: Excess use of packed attribute
Date: Wed, 09 Aug 2006 22:17:56 +0300
Message-ID: <44DA34E4.1030501@tcs.hut.fi>
References: <20060807133423.11bfbff3@localhost.localdomain> <20060807.162026.106265856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rdreier@cisco.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:35593 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1751292AbWHITR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 15:17:58 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.162026.106265856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 7 Aug 2006 13:34:23 -0700
> 
>> Silly offenders:	include/net/ipx.h
>> 			include/net/ieee80211.h
>> 			include/net/ip6_tunnel.h
>> 			include/net/ndisc.h
>> 			include/linux/if_ether.h
>> 			include/linux/if_fddi.h
>> 		
>> 			include/linux/sctp.h -- really bad
> 
> The ndisc.h one, for example, is needed for cases like ARM.
> 
> The if_ether.h one is also needed, or else for:
> 
> 	struct ethhdr *eth;
> 
> "eth + 1" would do the wrong thing as the compiler would
> align the structure to the native pointer size or similar.
> This is an issue because ethhdr is 14 bytes in size.

Similarly the ipv6_tlv_tnl_enc_lim in ip6_tunnel.h is a 3-octet IPv6
destination sub-option. The sub-option can be located anywhere inside
the destination option header and can only be found by parsing
the whole header.

Regards,
Ville
