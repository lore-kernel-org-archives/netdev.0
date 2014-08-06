From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware timestamp
 support
Date: Wed, 06 Aug 2014 13:19:37 -0700
Message-ID: <53E28DD9.6060503@intel.com>
References: <be459158bb5c46fcaf73129858342da4@FE-MBX1012.de.bosch.com>	<53E23BEF.9030701@cogentembedded.com>	<1407337757.772491.149802333.5E523CB0@webmail.messagingengine.com>	<53E24800.4030102@intel.com>	<53E2490E.70608@intel.com> <CAPDOMVgHmQeqOGj1MegRa=gusGXMn5t7cwCNnutpc1_q_fzyYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Koehrer Mathias <mathias.koehrer@etas.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPDOMVgHmQeqOGj1MegRa=gusGXMn5t7cwCNnutpc1_q_fzyYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2014 12:03 PM, Nick Krause wrote:
> On Wed, Aug 6, 2014 at 11:26 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> On 08/06/2014 08:21 AM, Alexander Duyck wrote:
>>> On 08/06/2014 08:09 AM, Henrique de Moraes Holschuh wrote:
>>>> On Wed, Aug 6, 2014, at 11:30, Sergei Shtylyov wrote:
>>>>> On 8/6/2014 6:27 PM, Koehrer Mathias (ETAS/ESW5) wrote:
>>>>>
>>>>>> With the Intel 82527EI (driver: e1000e) there is an issue when running
>>>>>> the ptpd2 program, that leads to a kernel oops.
>>>>>> The reason is here that in e1000_xmit_frame() a work queue will be
>>>>>> scheduled that has not been initialized in this case.
>>>>>> The work queue "tx_hwstamp_work" will only be initialized if
>>>>>> adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
>>>>>> This check is missing in e1000_xmit_frame().
>>>>>
>>>>>> The following patch adds the missing check.
>>>>>
>>>>>     OK, but this time you forgot your sign-off. :-)
>>>>
>>>> Also, shouldn't the added test be inside the unlikely() ?
>>>>
>>>
>>> That shouldn't be necessary, but it might be better to place the new
>>> check after the unlikely.  So you do the unlikely check first, then the
>>> adapter check to see if we support Tx timestamping.  That way we can
>>> avoid any unnecessary checks in the adapter structure.
>>>
>>> Thanks,
>>>
>>> Alex
>>>
>>
>>
>> Actually you might want to even take it one step further and break out
>> the test as follows (note this is only pseudo-code:
>>   unlikely(skb->tx_flags & HW_TSTAMP) &&
>>   (adapter->flags & HAS_HW_TSTAMP) &&
>>   !adapter->tx_hwtstamp_skb
>>
>> There isn't much point in wrapping the entire statement in unlikely, by
>> wrapping just the first test the rest of the conditional checks can be
>> pushed into the branch which will likely require a jump to some remote
>> block of code and should streamline the hot-path.
>>
>> Thanks,
>>
>> Alex
> 
> Alex,
> Has this patch been resent or not. If not I can clean it up and sent
> as my own patch against linus's tree.
> Regards NIck
> 

Nick,

Please give Mathias a chance to complete his own patch.  Also this is
would be against Dave Miller's net tree, not Linus's tree.

Thanks,

Alex
