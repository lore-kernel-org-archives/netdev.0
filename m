From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH net-next] net: display hw address of source machine during
 ipv6 DAD failure
Date: Mon, 30 Oct 2017 16:50:27 -0400
Message-ID: <5a65d720-37f3-3d83-afbe-d5e69400ec83@akamai.com>
References: <1509395380-28057-1-git-send-email-vpai@akamai.com>
 <2aa97226-9db7-e401-3e90-7c773e1e083b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: David Ahern <dsahern@gmail.com>, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00190b01.pphosted.com ([67.231.149.131]:35396 "EHLO
        mx0a-00190b01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932153AbdJ3Uu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:50:58 -0400
In-Reply-To: <2aa97226-9db7-e401-3e90-7c773e1e083b@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2017 04:43 PM, David Ahern wrote:
> On 10/30/17 2:29 PM, Vishwanath Pai wrote:
>> This patch updates the error messages displayed in kernel log to include
>> hwaddress of the source machine that caused ipv6 duplicate address
>> detection failures.
>>
>> Examples:
>>
>> a) When we receive a NA packet from another machine advertising our
>> address:
>>
>> ICMPv6: NA: 34:ab:cd:56:11:e8 advertised our address 2601::2bb4 on eth0!
> 
> your example above does not agree with the format below. You have the
> compressed IPv6 address, yet the format ...
> 
>>
>> b) When we detect DAD failure during address assignment to an interface:
>>
>> IPv6: eth0: IPv6 duplicate address 2601::2b78 used by 34:ab:cd:56:11:e8
>> detected!
>>
>> Suggested-by: Igor Lubashev <ilubashe@akamai.com>
>> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
>> ---
> 
> 
>> @@ -989,8 +990,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
>>  		 */
>>  		if (skb->pkt_type != PACKET_LOOPBACK)
>>  			ND_PRINTK(1, warn,
>> -				  "NA: someone advertises our address %pI6 on %s!\n",
>> -				  &ifp->addr, ifp->idev->dev->name);
>> +				  "NA: %pM advertised our address %pI6 on %s!\n",
> 
> ... is uncompressed. Please make that '%pI6c' instead of pI6 in the line
> above
> 
> 
>> +				  eth_hdr(skb)->h_source, &ifp->addr, ifp->idev->dev->name);
>>  		in6_ifa_put(ifp);
>>  		return;
>>  	}
> 
> 
> 

It does print out the full uncompressed IPv6 address. I modified the
message manually by hand while copying it out to the commit message in
order to hide the real IP address of my machines, but did not realize
that it was different from what the kernel would actually print out.

-Vishwanath
