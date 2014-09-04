From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [Patch net-next 04/11] net:fec: add multiqueue support
Date: Thu, 4 Sep 2014 09:02:59 -0500
Message-ID: <CAHrpEqSEG6qMCVnaLvB25dM+oEAMCSL6-pcTw9t2varL39wEmw@mail.gmail.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
	<1409776697-1536-5-git-send-email-Frank.Li@freescale.com>
	<540787B9.8090504@gmail.com>
	<CAHrpEqRSGg9=B8nk-PFkayP1kN8eQ5UnBvjikR5svub-wD-d6w@mail.gmail.com>
	<CAGVrzcaB=7qkXzZ46-86-obMJBTOZQ01N7PROdi9RrkiDnE2zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:61142 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbaIDODB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 10:03:01 -0400
In-Reply-To: <CAGVrzcaB=7qkXzZ46-86-obMJBTOZQ01N7PROdi9RrkiDnE2zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 11:09 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-09-03 20:41 GMT-07:00 Zhi Li <lznuaa@gmail.com>:
>> On Wed, Sep 3, 2014 at 4:27 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>> On 09/03/2014 01:38 PM, Frank Li wrote:
>>>> From: Fugang Duan <B38611@freescale.com>
>>>>
>>>> Add multiqueue support, which is compatible with previous single queue
>>>> driver for FEC/ENET IPs.
>>>>
>>>> By default, the tx/rx queue number is 1, user can config the queue number
>>>> at DTS file like this:
>>>>       fsl,num_tx_queues=<3>;
>>>>       fsl,num_rx_queues=<3>;
>>>>
>>>> Ethernet multiqueue mechanism can improve performance in SMP system.
>>>> For single hw queue, multiqueue can balance cpu loading.
>>>> For multi hw queues, multiple cores can process network packets in parallel,
>>>> and refer the article for the detail advantage for multiqueue:
>>>> http://vger.kernel.org/~davem/davem_nyc09.pdf
>>>
>>> You should probably split that patch in a minimum of two, or more
>>> different parts.
>>>
>>> Two parts:
>>>
>>> - add TX multiqueue support
>>> - add RX multiqueue support
>>>
>>
>> I understood your concern.
>> We also need consider logical integration.
>
> Sure, hence the reason why I suggest you make it happen in different
> parts, what you can do is make sure that you parse "fsl,num_tx_queues"
> and "fsl,num_rx_queues" as one of the last patches in this patch
> series. That way, we achieve a logical breakdown of the changes and
> only support and enable multiqueue when the driver is ready.

I can remove this part to "net:fec: add enet-avb IP support", last
patch just change DT file,
which come into difference maintainer.

But RX and TX is difficult to separate because RX and TX share some
function, such as
fec_enet_get_nextdesc

If I change TX part,  fec_enet_get_nextdesc will add a parameter. If
that, all RX part need be
changed.

>
>>
>> Separate this patch just reduce changed lines in a patch.
>
> That is exactly my point, right now there is too much churn to make a
> reviewer able to spot potential problems.
>
>> Most of this patch change is from fep-> to txq-> or rxq->
>>
>> best regards
>> Frank Li
>>
>>> More parts:
>>>
>>> - prepare for TX multiqueue (introduce queue structure, definitions)
>>> - transition TX path to use queue 0
>>> - add support for the two other TX queues
>>> - prepare for RX multiqueue (introduce queue structure, definitions)
>>> - prepare for multiqueue, hardcode RX path to use queue 0
>>> - add support for the two other RX queues
>>>
>>> The number of changes are extremely hard to review...
>>> --
>>> Florian
>
>
>
> --
> Florian
