From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v3 net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Fri, 13 Dec 2013 07:48:18 +0800
Message-ID: <CAPshTCj-N6d0astJAQZa-qqCCgdcidbjsNLCZcydsw8EAH1hsw@mail.gmail.com>
References: <1386824025-27413-1-git-send-email-hkchu@google.com>
	<20131212.134808.116829709834251220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ranjit Manomohan <ranjitm@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:38015 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab3LLXsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:48:20 -0500
Received: by mail-qc0-f178.google.com with SMTP id i17so927278qcy.37
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 15:48:19 -0800 (PST)
In-Reply-To: <20131212.134808.116829709834251220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 2:48 AM, David Miller <davem@davemloft.net> wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Wed, 11 Dec 2013 20:53:45 -0800
>
>> From: Jerry Chu <hkchu@google.com>
>>
>> This patch modifies the GRO stack to avoid the use of "network_header"
>> and associated macros like ip_hdr() and ipv6_hdr() in order to allow
>> an arbitary number of IP hdrs (v4 or v6) to be used in the
>> encapsulation chain. This lays the foundation for various IP
>> tunneling support (IP-in-IP, GRE, VXLAN, SIT,...) to be added later.
>>
>> With this patch, the GRO stack traversing now is mostly based on
>> skb_gro_offset rather than special hdr offsets saved in skb (e.g.,
>> skb->network_header). As a result all but the top layer (i.e., the
>> the transport layer) must have hdrs of the same length in order for
>> a pkt to be considered for aggregation. Therefore when adding a new
>> encap layer (e.g., for tunneling), one must check and skip flows
>> (e.g., by setting NAPI_GRO_CB(p)->same_flow to 0) that have a
>> different hdr length.
>>
>> Note that unlike the network header, the transport header can and
>> will continue to be set by the GRO code since there will be at
>> most one "transport layer" in the encap chain.
>>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
>> Reviewed-by: Eric Dumazet <edumazet@google.com>
>
> Applied, thanks.

Thanks, David. I will submit a patch for GRE soon to demonstrate
just how easy it is to add tunneling support to GRO after the assumption
of only one IP hdr in the encap chain is removed. (I already have the
code but it doesn't support the CSUM flag. I'm thinking adding it
plus csum offload support before submitting the patch.)

Best,

Jerry
