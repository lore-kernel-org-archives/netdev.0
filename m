From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/3] mpls: multipath support
Date: Thu, 13 Aug 2015 14:46:58 +0100
Message-ID: <55CC9FD2.8090001@brocade.com>
References: <1439329548-50935-1-git-send-email-roopa@cumulusnetworks.com>
 <55CB82A6.8070800@brocade.com> <55CBFBD6.50603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36508 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753045AbbHMNre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 09:47:34 -0400
In-Reply-To: <55CBFBD6.50603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/08/15 03:07, roopa wrote:
> On 8/12/15, 10:30 AM, Robert Shearman wrote:
>> On 11/08/15 22:45, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch series adds multipath support to mpls routes.
>>>
>>> resembles ipv4 multipath support. The multipath route nexthop
>>> selection algorithm is the same code as in ipv4 fib code.
>>>
>>> I understand that the multipath algorithm in ipv4 is undergoing
>>> some changes and will move mpls to similar algo if applicable once
>>> those get merged.
>>
>> Is it necessary for the mpls patch selection algorithm to closely
>> resemble the ipv4 one?
> No, It is not necessary. I picked that because it was already there. And
> I see that ipv4 is also getting some new multipath algorithms
> (https://marc.info/?l=linux-api&m=143457208315573&w=2). I wanted to move
> to the new RT_MP infra if that becomes applicable in the future.

The MPLS code doesn't have the binary compatibility requirement that the 
IPv4 path does, so there isn't so much of a need for the algorithm to be 
configurable, provided the default is reasonable. Unless you have a use 
case in mind that would particularly suited to the round-robin algorithm?

>
>> A flow based algorithm would be much better for traffic that is
>> sensitive to re-ordering (e.g TCP, L2VPN) and IMHO we should do this
>> from the start for MPLS.
>>
>> I've also been looking at implementing this functionality. I've got a
>> set of patches for this that I can send if you'd like.
>
> Definitely. But, It seems like you can also submit incremental patches
> to mine. You can replace the current algo with a hash based with your
> patches.

With a flow-based algorithm if there's no need to support weighted paths 
then there's no need to iterate through the nexthops to work out which 
one should be used and, therefore, there is a performance benefit.

So my patches implement a flow-based path selection without support for 
weighted paths. This is similar way to how the IPv6 path selection 
works. The user can still do UCMP with this mechanism, but they have to 
add the same nexthop multiple times. I don't know if this trade-off is 
worth it, but the benefit is that we can always add support for weighted 
paths in the future, whereas removing support for weighted paths would 
be harder due to compatibility concerns.

Therefore, if I rebased my patches on top of yours I would be removing 
code managing the weighting that you will have just added. Not sure if 
that is desirable.

> If that does not work for you and if you want me to merge with this
> series that works too.

I think that would work better. I'll send you a patch against your 
current series.

Thanks,
Rob
