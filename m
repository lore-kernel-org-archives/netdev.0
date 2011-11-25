From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Fri, 25 Nov 2011 19:31:55 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111251925100.32630@frira.zrqbmnf.qr>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-2-git-send-email-hans@schillstrom.com> <20111125173649.GA9304@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans@schillstrom.com>, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:55337 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab1KYSb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 13:31:57 -0500
In-Reply-To: <20111125173649.GA9304@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2011-11-25 18:36, Pablo Neira Ayuso wrote:

>On Fri, Nov 25, 2011 at 10:36:26AM +0100, Hans Schillstrom wrote:
>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>> index 3f0258d..9e4d4f9 100644
>> --- a/include/net/ipv6.h
>> +++ b/include/net/ipv6.h
>> @@ -39,6 +39,7 @@
>>  #define NEXTHDR_ICMP		58	/* ICMP for IPv6. */
>>  #define NEXTHDR_NONE		59	/* No next header */
>>  #define NEXTHDR_DEST		60	/* Destination options header. */
>> +#define NEXTHDR_SCTP		132	/* Stream Control Transport Protocol */
>>  #define NEXTHDR_MOBILITY	135	/* Mobility header. */
>>  
>>  #define NEXTHDR_MAX		255
>
>This has to go in a separated patch. Please, send it to netdev. I
>think davem can pick that for 3.2-rc

I do have to wonder a little why we need the l4proto values twice 
(IPPROTO_SCTP plus NEXTHDR_SCTP). Has nobody ever thought of
doing one foobar_<PROTOCOL>?

>> +	    icmph->type != ICMP_REDIRECT)
>> +		return nhoff;
>> +	/* Checkin full IP header plus 8 bytes of protocol to
>> +	 * avoid additional coding at protocol handlers.
>> +	 */
>> +	if (!pskb_may_pull(skb, nhoff + iphsz + sizeof(_ih) + 8))
>> +		return nhoff;

NB:I point out that the preferred long comment style begins with /*\n 
(to match the trailing \n*/, naturally) like in

>> +/*
>> + * ICMPv6
>> + * Input nhoff Offset into network header
>> + *       offset where ICMPv6 header starts
>> + * Returns true if it's a icmp error and updates nhoff
>> + */
