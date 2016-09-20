From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 11:19:44 -0400
Message-ID: <57E15390.9030306@akamai.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
 <BL2PR07MB23061EAE5CF41EE56A1ED99B8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E14D24.40504@akamai.com>
 <BL2PR07MB2306ECB3DBAB53BFB9CF30EC8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:20203 "EHLO
        prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754001AbcITPZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 11:25:02 -0400
In-Reply-To: <BL2PR07MB2306ECB3DBAB53BFB9CF30EC8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/20/2016 11:00 AM, Mintz, Yuval wrote:
>>> The question I rose was whether it actually makes a difference under
>>> such circumstances whether the device would actually filter those
>>> multicast addresses or be completely multicast promiscuous.
>>> e.g., whether it's significant to be filtering out multicast ingress
>>> traffic when you're already allowing 1/2 of all random multicast
>>> packets to be classified for the interface.
>>>
>>
>> Agreed, I think this is the more interesting question here. I thought that we
>> would want to make sure we are using most of the bins before falling back to
>> multicast ingress. The reason being that even if its more expensive for the NIC to
>> do the filtering than the multicast mode, it would be more than made up for by
>> having to drop the traffic higher up the stack. So I think if we can determine the
>> percent of the bins that we want to use, we can then back into the average
>> number of filters required to get there. As I said, I thought we would want to
>> make sure we filled basically all the bins (with a high probability that is) before
>> falling back to multicast, and so I threw out 2,048.
>
> AFAIK configuring multiple filters doesn't incur any performance penalty
> from the adapter side.
> And I agree that from 'offloading' perspective it's probably better to
> filter in HW even if the gain is negligible.
> So for the upper limit - there's not much of a reason to it; The only gain
> would be to prevent driver from allocating lots-and-lots of memory
> temporarily for an unnecessary configuration.
>

Ok. We already have an upper limit to an extent with 
/proc/sys/net/ipv4/igmp_max_memberships. And as posted I didn't include 
one b/c of the higher level limits already in place.

Thanks,

-Jason
