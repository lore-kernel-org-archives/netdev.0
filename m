From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 19:39:41 +0100
Message-ID: <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
 <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Anton Ivanov <anton.ivanov@cambridgegreys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36647 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdJKTUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:20:09 -0400
In-Reply-To: <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check as now insists that the actual driver supports GSO_ROBUST, 
because we have marked the skb dodgy.

The specific bit which does this check is in net_gso_ok()

Now, lets's see how many Ethernet drivers set GSO_ROBUST.

find drivers/net/ethernet -type f -name "*.[c,h]" -exec grep -H 
GSO_ROBUST {} \;

That returns nothing in 4.x

IMHO - af_packet allocates the skb, does all checks (and extra may be 
added) on the gso, why is this set dodgy in the first place?

A.


On 11/10/17 17:26, Willem de Bruijn wrote:
> On Wed, Oct 11, 2017 at 11:54 AM, Anton Ivanov
> <anton.ivanov@cambridgegreys.com> wrote:
>> It is that patch.
>>
>> I rolled it back and immediately got it to work correctly on a Broadcom
>> Tigon. I can test on all other scenarios, I have tried, I suspect it will
>> come back alive on all of them.
>>
>> I am going to try to trace it through and see exactly where it drops a skb
>> which the card has no issues in accepting.
> It might be in the initialization of gso_type and csum. The virtio_net_hdr
> can encode various combinations of flags that are not allowed by the
> validation logic.
>
