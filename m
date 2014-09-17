From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages
 for smaller port MTUs
Date: Wed, 17 Sep 2014 18:03:51 -0400
Message-ID: <541A0547.3000403@oracle.com>
References: <5419F3E5.4050708@oracle.com> <5419F97C.1080105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51716 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998AbaIQWD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:03:58 -0400
In-Reply-To: <5419F97C.1080105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/17/2014 05:13 PM, Sergei Shtylyov wrote:

>> +        }
>> +#if IS_ENABLED(CONFIG_IPV6)
> 
>    This #if could be avoided by extending the *if* statement below, no?
> 
>> +        else if (skb->protocol == htons(ETH_P_IPV6))
>> +            icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, localmtu);
>> +#endif
>>           goto out_dropped;
>> +    }

I'm not sure I understand your point, but the #if must be there to
avoid a reference to icmpv6_send() which will not be defined if
CONFIG_IPV6=n.

						+-DLS
