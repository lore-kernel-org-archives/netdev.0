From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 3/4] bluetooth: hci_uart: add LL protocol serdev driver support
Date: Fri, 7 Apr 2017 13:48:52 -0500
Message-ID: <CAL_Jsq+aM+xxbu=3v8_w9Ce+=t_pXmVWuisnckA8_8LOS-ftVA@mail.gmail.com>
References: <20170407143516.9945-1-robh@kernel.org> <1491584978.2136.21.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Wei Xu <xuwei5@hisilicon.com>, Eyal Reizer <eyalr@ti.com>,
        Satish Patel <satish.patel@linaro.org>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58038 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754489AbdDGStR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 14:49:17 -0400
In-Reply-To: <1491584978.2136.21.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 7, 2017 at 12:09 PM, Dan Williams <dcbw@redhat.com> wrote:
> On Fri, 2017-04-07 at 09:35 -0500, Rob Herring wrote:
>> Turns out that the LL protocol and the TI-ST are the same thing
>> AFAICT.
>> The TI-ST adds firmware loading, GPIO control, and shared access for
>> NFC, FM radio, etc. For now, we're only implementing what is needed
>> for
>> BT. This mirrors other drivers like BCM and Intel, but uses the new
>> serdev bus.
>>
>> The firmware loading is greatly simplified by using existing
>> infrastructure to send commands. It may be a bit slower than the
>> original code using synchronous functions, but the real bottleneck is
>> likely doing firmware load at 115.2kbps.
>
> Is there no way to put the TI-specific stuff into a TI UART module
> rather than building it into the generic one?

In case it's not clear, all of HCI_LL is the TI specific part, not
just what I'm adding. So you are talking about putting each UART BT
protocol into a separate module. I'd assume that is doable, but seems
orthogonal to this patch set. I'd also assume there was some reason
that was not done already.

Rob
