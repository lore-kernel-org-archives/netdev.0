From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 1/2] mpls: allow TTL propagation to IP packets
 to be configured
Date: Fri, 10 Mar 2017 10:12:20 +0000
Message-ID: <6912a3a7-fd29-20cc-1f61-9f1b7fc3e7b1@brocade.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-2-git-send-email-rshearma@brocade.com>
 <4711aeb8-5da5-4a2b-7304-6b9696e8c1cb@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:55766 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933511AbdCJKMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 05:12:34 -0500
In-Reply-To: <4711aeb8-5da5-4a2b-7304-6b9696e8c1cb@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/17 02:00, David Ahern wrote:
> On 3/7/17 5:46 PM, Robert Shearman wrote:
>> @@ -244,24 +245,33 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>>  		payload_type = ip_hdr(skb)->version;
>>
>>  	switch (payload_type) {
>> -	case MPT_IPV4: {
>> -		struct iphdr *hdr4 = ip_hdr(skb);
>> +	case MPT_IPV4:
>> +		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
>> +		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
>> +		     net->mpls.ip_ttl_propagate)) {
>> +			struct iphdr *hdr4 = ip_hdr(skb);
>> +
>> +			csum_replace2(&hdr4->check,
>> +				      htons(hdr4->ttl << 8),
>> +				      htons(dec.ttl << 8));
>> +			hdr4->ttl = dec.ttl;
>> +		}
>>  		skb->protocol = htons(ETH_P_IP);
>> -		csum_replace2(&hdr4->check,
>> -			      htons(hdr4->ttl << 8),
>> -			      htons(dec.ttl << 8));
>> -		hdr4->ttl = dec.ttl;
>>  		success = true;
>>  		break;
>> -	}
>> -	case MPT_IPV6: {
>> -		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
>> +	case MPT_IPV6:
>> +		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
>> +		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
>> +		     net->mpls.ip_ttl_propagate)) {
>> +			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
>> +
>> +			hdr6->hop_limit = dec.ttl;
>> +		}
>>  		skb->protocol = htons(ETH_P_IPV6);
>> -		hdr6->hop_limit = dec.ttl;
>>  		success = true;
>>  		break;
>> -	}
>
> What decrements the TTL if it is not propagated from MPLS to IP?
>

Good point. Will address in v3.

Thanks,
Rob
