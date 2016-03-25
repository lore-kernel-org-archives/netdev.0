From: Ben Greear <greearb@candelatech.com>
Subject: Re: veth regression with =?windows-1252?Q?=22don=92t_modify_?=
 =?windows-1252?Q?ip=5Fsummed=3B_doing_so_treats_packets_with_?=
 =?windows-1252?Q?bad_checksums_as_good=2E=22?=
Date: Fri, 25 Mar 2016 10:14:46 -0700
Message-ID: <56F57206.5000701@candelatech.com>
References: <56F4C8FD.7030907@candelatech.com>	<CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>	<56F56312.4080408@candelatech.com> <20160325.124427.273071525698476869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, vijayp@vijayp.ca, netdev@vger.kernel.org,
	ej@evanjones.ca, cwang@twopensource.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:38788 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbcCYROs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 13:14:48 -0400
In-Reply-To: <20160325.124427.273071525698476869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/2016 09:44 AM, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 25 Mar 2016 09:10:58 -0700
>
>> I am suspicious that this will break at least some drivers.  I
>> grepped around for ip_summed, and found this, for instance:
>>
>> davicom/dm9000.c
>>
>>          /* The DM9000 is not smart enough to leave fragmented packets
>
> An really old (circa 1997), not-oft-used, driver such as this is not
> the place to be looking for correct usage of skb->ip_summed semantics.
>
> I would never use whatever a driver like this does influence whether I
> apply a bug fix or not.


Point is, it took me 5 minutes to find that, and I did not look hard at many
other drivers.  e1000e and igb appear to be fine, and maybe the rest of them
are too.  Lord knows what other strange setups might be effected by the
ip_summed change.

Anyway, you know the stack and drivers better than me, so if you think Cong's
patch is valid, then I'll test it and make sure it works in my setups at least.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
