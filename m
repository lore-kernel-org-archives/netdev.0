From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [RFC] Re: Re: stmmac ethernet in kernel 4.9-rc6: coalescing
 related pauses.
Date: Wed, 7 Dec 2016 14:18:19 +0100
Message-ID: <c9169edc-3144-fab1-d176-7a8b9b3e4366@marvell.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <trinity-11729d3e-ae5e-4850-a1bf-b83a1d0a864c-1480687521037@3capp-gmx-bs55>
 <20161207123140.GA8785@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, David Miller <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207123140.GA8785@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 07.12.2016 13:31, Pavel Machek wrote:
> On Fri 2016-12-02 15:05:21, Lino Sanfilippo wrote:
>> Hi,
>>
>>
>>>
>>> There's nothing that protect stmmac_poll() from running concurently
>>> with stmmac_dma_interrupt(), right?
>>>
>>
>> could it be that there is also another issue concerned locking?:
>> The tx completion handler takes the xmit_lock in case that the
>> netif_queue is stopped. This is AFAICS unnecessary, since both
>> xmit and completion handler are already synchronized by the private
>> tx lock. But it is IMHO also dangerous:
>>
>> In the xmit handler we have the locking order
>> 1. xmit_lock
>> 2. private tx lock
>>
>> while in the completion handler its the reverse:
>>
>> 1. private tx lock
>> 2. xmit lock.
>>
>> Do I miss something?
>
> No, it seems you are right. Something like this?
>
> Hmm. And can priv->tx_lock be removed, as we already rely on
> netif_tx_lock?
>

David wanted indeed the private lock to be removed completely. See
this thread.

https://marc.info/?l=linux-netdev&m=148072001900620&w=2

If you can wait a bit, I already have patches prepared to fix this issue in both
drivers. I want to send them as soon as I am at home (a few hours).

Regards,
Lino
