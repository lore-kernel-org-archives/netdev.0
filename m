From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 17:52:59 +0200
Message-ID: <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:35117 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751648AbdHBPxM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 11:53:12 -0400
In-Reply-To: <yw1xshhagexd.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 17:36, Måns Rullgård wrote:

> Mason wrote:
> 
>> Looking at the tango-specific integration, I note this nugget:
>>
>> 1.5.4 Stopping & Starting the DMA
>>
>> This feature has been added to allow the software to stop and start
>> the DMA without any issues.
>>
>> Procedure:
>> 1- STOP:
>> 2- Stop RX core;
>> 3- Set OWN bit of all descriptor of the chain to 1;
>> 4- Stop DMA by writing dma_stop bit to 1 in  RX_DMA_Stop register
>> 5- Wait around 100 clock cycles.
>>
>> The pending packets are held until the system will re-start.
>>
>> RE-START:
>> 1- Clear dma_stop bit (note that if at the time of stopping the DMA,
>> the next packet in the FIFO was an UDP packet, when clearing dma_stop,
>> this packet will directly start being written in the DRAM since UDP
>> packets are not controlled by the descriptor mechanism);
>> 2- Program a new chain of descriptor;
>> 3- Re-enable DMA (rx_ctrl register)
>>
>> rx_dma_stop:
>> Software control to stop the Rx DMA.
>> A write to this bit with "1" will gracefully stop the Rx DMA by after
>> transferring the current packet. If more packets are pending they will
>> be held until the software clears this bit.
>>
>> Hmmm, what do you think? This looks promising...
> 
> This is only available in the more recent Sigma versions.  Although it
> is nicer, I didn't think it was worth the trouble to support both
> methods since the older method should work on all chips.

Well, from my perspective, the older method does not
work on newer chips :-)

The "new" method is available on the SMP8670 onward
(released Jan 2011). I might try implementing it for
"sigma,smp8734-ethernet" boards.

Regards.
