From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [Intel-wired-lan] Question on ixgbe flow director
Date: Wed, 8 Mar 2017 11:30:54 -0800
Message-ID: <5e81301b-f660-43a5-3400-8cbf7d3a77aa@oracle.com>
References: <c5c170c0-a024-5cb2-cd39-81b8cfffd8e5@oracle.com>
 <CAKgT0UfT9zdzPHQawFtGZf9k1mwHG5_jZorXNDsoiOrUfNnZJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        netdev <netdev@vger.kernel.org>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:27739 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754162AbdCHVRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 16:17:35 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v28JXTf2016294
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Wed, 8 Mar 2017 19:33:29 GMT
In-Reply-To: <CAKgT0UfT9zdzPHQawFtGZf9k1mwHG5_jZorXNDsoiOrUfNnZJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/08/2017 07:39 AM, Alexander Duyck wrote:
> On Tue, Mar 7, 2017 at 3:43 PM, tndave <tushar.n.dave@oracle.com>
> wrote:
>> Hi,
>>
>> I have few questions regarding ixgbe flow director. As per my
>> understanding flow director in ixgbe can work in 2 exclusive ways,
>>  a. Using ATR filters - where flow director is setup in HW by
>> driver identifying transmit traffic. And based on that, receive
>> traffic of the same flow get assigned/directed to same queue.
>
> So ATR for ixgbe uses the Flow Director signature filters. Basically
> the signature filters are purely hash based filters.  The easiest way
> to think of it is it is essentially a beefed up version of RSS.
Alex,

Thanks for the info.
>
>> b. Perfect filter, where user can manually program flow director
>> using ethtool so that receive packets gets directed to specified
>> rx queue (depending on on how ethtool flow-type and action etc,.);
>> But with perfect filters there is no intelligence involved alike
>> ATR has on identifying transit, right?
>
> You are right.  The perfect match filters are the ones we configure
> via ethtool.  You are correct in that ATR logic is not involved so
> there is no matching up an Rx flow to a Tx flow.
>
>> Few question regarding ixgbe ATR, 1. does ATR works in case if
>> protocol is UDP? (Based on the current ixgbe_atr() it only
>> supports TCP)
>
> It could, but the software for doing ATR flow identification,
> ixgbe_atr(), only works on TCP.  The reasoning behind it is that Flow
> Director doesn't filter fragmented frames and UDP can be fragmented.
So we could just add code in ixgbe_atr() for non-fragmented udp packets!
However question is if it is going to work w.r.t ATR? TCP is connected
stream vs udp is stateless and single udp socket can talk to multiple
endpoints.

>
>> 2. Does ATR flow director can be programmed using ethtool? (As per
>> my understanding only perfect filter can be programmed from
>> ethtool, is that so?)
>
> You can enable/disable the ATR filters via the NTUPLE feaure flag.
> Basically it toggles between ATR mode, and NTUPLE mode.  In NTUPLE
> mode the perfect filters are enabled and can be configured via
> ethtool.
Got it.

Thanks.

-Tushar
>
>> Thanks in advance, -Tushar
>
> Hope that helps.
>
> - Alex
>
