From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 19 Jun 2015 18:25:16 +0100
Message-ID: <5584507C.2000303@brocade.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <55842A93.2040607@brocade.com> <558431C3.5020703@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ebiederm@xmission.com>, <tgraf@suug.ch>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:12287 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752406AbbFSRZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 13:25:51 -0400
In-Reply-To: <558431C3.5020703@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

n 19/06/15 16:14, roopa wrote:
> On 6/19/15, 7:43 AM, Robert Shearman wrote:
>>>
>>> +
>>> +static inline struct lwtunnel_state *lwtunnel_skb_lwstate(struct
>>> sk_buff *skb)
>>> +{
>>> +    struct rtable *rt = (struct rtable *)skb_dst(skb);
>>> +
>>> +    return rt->rt_lwtstate;
>>> +}
>>
>> It doesn't look like this patch will build on its own because
>> rt_lwtstate isn't added to struct rtable until patch 2.
> looks like i messed up the patch creation. I will fix that with the next
> series.
>>
>> More importantly, is it safe to assume that skb_dst will always return
>> an IPv4 dst? How will this look when IPv6 support is added?
>
> Today lwtunnel_skb_lwstate is called from lwtunnel_output which is only
> called from ipv4 code.
> And my ipv6 variant code was supposed to have a 6 suffix. something like
> lwtunnel_output6.
> Or to be more explicit i will probably have variants of the output and
> skb handling functions like,
> lwtunnel_output_ipv4 and lwtunnel_output_ipv6.

Do you intend for these functions to be used by netdevices to support 
the vxlan use case?

If so, then how will the netdevice know which one of the two to call? 
Will there have to be a netdevice for ipv4 and a netdevice for ipv6?

If not, could you outline how you intend for it to be implemented?

Thanks,
Rob
