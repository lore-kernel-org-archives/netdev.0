From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 17:32:21 +0100
Message-ID: <bd4f863d-e39a-c31f-712f-1720af8e0024@cambridgegreys.com>
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
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36638 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757030AbdJKQcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 12:32:24 -0400
In-Reply-To: <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Working through it at the moment.

The validation logic is prohibiting what the hardware considers to be a 
perfectly legit skb.

Once I narrow down the culprit I will come back with my findings.

Thanks for pointing me where to look by the way.

A.

On 10/11/17 17:26, Willem de Bruijn wrote:
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

-- 
Anton R. Ivanov

Cambridge Greys Limited, England and Wales company No 10273661
http://www.cambridgegreys.com/
