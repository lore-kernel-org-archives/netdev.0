From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 2/2] mpls: allow TTL propagation from IP
 packets to be configured
Date: Fri, 10 Mar 2017 10:12:36 +0000
Message-ID: <e127dbdb-2842-e600-6f41-6ac458eaa530@brocade.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-3-git-send-email-rshearma@brocade.com>
 <3a3b0cfe-106c-88ee-e225-0df1458aab4b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:55805 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755376AbdCJKMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 05:12:49 -0500
In-Reply-To: <3a3b0cfe-106c-88ee-e225-0df1458aab4b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/17 02:54, David Ahern wrote:
> On 3/7/17 5:46 PM, Robert Shearman wrote:
>> @@ -78,6 +70,29 @@ static int mpls_xmit(struct sk_buff *skb)
>>
>>  	tun_encap_info = mpls_lwtunnel_encap(dst->lwtstate);
>>
>> +	/* Obtain the ttl */
>> +	if (dst->ops->family == AF_INET) {
>> +		if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DISABLED)
>> +			ttl = tun_encap_info->default_ttl;
>> +		else if (tun_encap_info->ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
>> +			 !net->mpls.ip_ttl_propagate)
>> +			ttl = net->mpls.default_ttl;
>> +		else
>> +			ttl = ip_hdr(skb)->ttl;
>
> After staring at that for a while, an explanation above this if {} else
> {} section on the ttl selection will be very helpful.
>

Ok, would a comment like the following improve things sufficiently?

	/* Obtain the ttl using the following set of rules.
	 *
	 * LWT ttl propagation setting:
	 *  - disabled => use default TTL value from LWT
	 *  - enabled  => use TTL value from IPv4/IPv6 header
	 *  - default  =>
	 *   Global ttl propagation setting:
	 *    - disabled => use default TTL value from global setting
	 *    - enabled => use TTL value from IPv4/IPv6 header
	 */

Thanks,
Rob
