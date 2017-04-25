From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: bridge: suppress broadcast when multicast flood is
 disabled
Date: Tue, 25 Apr 2017 14:32:44 +0100
Message-ID: <a96ddd28-6d99-84d0-563a-2493a09a9e60@brocade.com>
References: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
 <5266c6fd-54e9-01c7-2379-0b7f11a3cde3@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        roopa <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:56774 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1176486AbdDYNdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 09:33:00 -0400
In-Reply-To: <5266c6fd-54e9-01c7-2379-0b7f11a3cde3@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/17 20:52, Nikolay Aleksandrov wrote:
> On 24/04/17 17:09, Mike Manning wrote:
>> Flood suppression for packets that are not unicast needs to be handled
>> consistently by also not flooding broadcast packets. As broadcast is a
>> special case of multicast, the same kernel parameter should be used to
>> suppress flooding for both of these packet types.
>>
>> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
>> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> ---
>>  net/bridge/br_forward.c | 17 ++++++++++-------
>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>
> 
> I do not agree that this is a bug fix, the behaviour was intentional and is close to how HW
> handles this flag. It has been like that for a few releases and changing it may impact setups
> that use the flag since up until now they've seen the broadcast but not multicast packets and
> suddenly their broadcast will stop.
> 
> I think it would be better to introduce a third flag for bcast in net-next and use that to
> filter it since that would give us the ability to program HW that can distinguish these
> and have both options available, moreover it will not break any user setups relying on
> the current flag behaviour and we have such setups.
> 
> Thanks,
>  Nik
> 
> 

Hi Nik,
What is the usecase for flooding broadcast but not multicast please? Is the lack of flood
suppression for broadcast just something that has not been explicitly tested for in those
setups? This is the case for us, the bug raised only at this stage of the release cycle.
While adding another kernel param is an option, I would only do so if absolutely necessary
so as to avoid proliferation of params. Also to justify adding such a flag for broadcast
suppression, I would need to add a comment to explain that while broadcast is a subset of
multicast, the multicast flood suppression flag excludes broadcast.

Thanks
Mike
