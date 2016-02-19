From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Fri, 19 Feb 2016 09:57:47 +0000
Message-ID: <56C6E71B.3080509@brocade.com>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
 <1454700472-13543-2-git-send-email-rshearma@brocade.com>
 <20160216.104115.1576720778383292937.davem@davemloft.net>
 <56C385E0.2000405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ebiederm@xmission.com>
To: roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:56762 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1427374AbcBSJ6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 04:58:03 -0500
In-Reply-To: <56C385E0.2000405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/02/16 20:26, roopa wrote:
> On 2/16/16, 7:41 AM, David Miller wrote:
>> Statistics not provided via netlink are useless in real installations.
>>
>> In fact I would say to forego the proc interface entirely, it's a second
>> class citizen for statistics gathering and has a non-triviel per-device
>> cost for instantiation.
>>
> +1
>
> I agree with the cost too.
>
> Robert, I was thinking of responding to your series to add netlink stats for AF_MPLS in
>   rtnl_af_ops (similar to  IFLA_INET6_STATS). But, soon realized that it is currently used by ipv6 alone
> and it also ended up with a skip filter (RTEXT_FILTER_SKIP_STATS). So, extending that interface for
> mpls is not the right thing to do either.

ipv4 doesn't have per-interface stats, so the fact that it doesn't use 
fill_link_af to export stats doesn't really add much to the argument.

The real issue with the IFLA_INET6_STATS mechanism is that they are 
included in netlink broadcasts, not just netlink unicasts and there is 
no way of filtering for broadcasts at the moment.

> There is work being done for a separate netlink infrastructure for stats.
> I would wait for that infrastructure to be ready to add mpls stats. It should be available soon.

Great, any details on what it would look like? Can I assist in any way 
in the development?

In the mean time, I'll rebase and resubmit the ip ttl propagation patch 
separately.

Thanks,
Rob
