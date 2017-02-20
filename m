From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] net: mpls: Add support for netconf
Date: Mon, 20 Feb 2017 15:53:27 +0000
Message-ID: <43594433-2c08-6700-9687-06d2d05caeed@brocade.com>
References: <1487381793-12234-1-git-send-email-dsa@cumulusnetworks.com>
 <9326b299-3969-7e0e-dba4-fae5682f0b24@brocade.com>
 <5c606636-64bb-a40b-c4bc-6292c5dc7678@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>,
        <nicolas.dichtel@6wind.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46481 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753513AbdBTPxm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:53:42 -0500
In-Reply-To: <5c606636-64bb-a40b-c4bc-6292c5dc7678@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/02/17 14:53, David Ahern wrote:
> On 2/20/17 3:01 AM, Robert Shearman wrote:
>> On 18/02/17 01:36, David Ahern wrote:
>>> Add netconf support to MPLS. Allows userpsace to learn and be notified
>>> of changes to 'input' enable setting per interface.
>>>
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>> ---
>>>  include/uapi/linux/netconf.h   |   1 +
>>>  include/uapi/linux/rtnetlink.h |   2 +
>>>  net/mpls/af_mpls.c             | 212
>>> ++++++++++++++++++++++++++++++++++++++++-
>>>  net/mpls/internal.h            |   2 +-
>>>  4 files changed, 214 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
>>> index 45dfad509c4d..159d91c9c2a3 100644
>>> --- a/include/uapi/linux/netconf.h
>>> +++ b/include/uapi/linux/netconf.h
>>> @@ -16,6 +16,7 @@ enum {
>>>      NETCONFA_MC_FORWARDING,
>>>      NETCONFA_PROXY_NEIGH,
>>>      NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
>>> +    NETCONFA_MPLS_INPUT_ENABLED,
>>
>> How about removing "MPLS_" the name? That way it would be usable by
>> other AFs too, e.g. for the disable_ipv6 sysctl. Perhaps "ENABLED" is
>> redundant as well.
>
>
> I could drop the MPLS to NETCONFA_INPUT_ENABLED; just NETCONFA_INPUT is
> not very descriptive.
>
> disable_ipv6 has a completely different meaning, so re-use there does
> not seem appropriate.

That's a fair point - disable_ipv6 does more than just disabling the 
input of IPv6 packets. However, the point still stands in the general 
sense - why tie the attribute name to an AF if it's not necessary?

Thanks,
Rob

> Thanks for the review.
>
