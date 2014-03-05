From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net: davinci_emac: Move call of devm_request_irq to
 emac_dev_open
Date: Wed, 05 Mar 2014 08:12:41 +0100
Message-ID: <1178CE306BD3D17142544A7E@[172.22.2.41]>
References: <5dd177ee-f4e8-47b0-aeb8-d2fa64d3725b@mary.at.omicron.at>
 <CA+V-a8v9qx4Q37ux+uuqzSSNXengYn=97Uq+5x4awPK01TaOKQ@mail.gmail.com>
 <CAGVrzcbDRPDvjf=6_BHATmXJUzXB_20yvoYgujgp_rYOemJZPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jon Ringle <jon@ringle.org>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	stable <stable@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcbDRPDvjf=6_BHATmXJUzXB_20yvoYgujgp_rYOemJZPA@mail.gmail.com>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--On March 04, 2014 09:53 -0800 Florian Fainelli <f.fainelli@gmail.com> 
wrote:

> 2014-03-04 9:30 GMT-08:00 Prabhakar Lad <prabhakar.csengg@gmail.com>:
>> Hi Christian,
>>
>> Thanks for the patch.
>>
>>
>> On Tue, Mar 4, 2014 at 7:37 PM, Christian Riesch
>> <christian.riesch@omicron.at> wrote:
>>> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>>>
>>> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>>> Date:   Tue Jun 25 21:24:51 2013 +0530
>>> net: davinci: emac: Convert to devm_* api
>>>
>>> the call of request_irq is replaced by devm_request_irq and the call
>>> of free_irq is removed. But since interrupts are requested in
>>> emac_dev_open, doing ifconfig up/down on the board requests the
>>> interrupts again each time, causing devm_request_irq to fail.
>>>
>>> This patch moves the interrupt requests to emac_dev_open and thus
>>> fixes this regression.
>>>
>>> Reported-by: Jon Ringle <jon@ringle.org>
>>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>>> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>>> Cc: <stable@vger.kernel.org>
>>
>> This patch fixes issue pointed at
>> http://comments.gmane.org/gmane.linux.davinci/28135
>> tested on Logic PD.
>>
>>  Reported-and-tested-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>>
>> Assuming you will respin the patch fixing the header.
>>> ---
>>>
>>> Hi,
>>> This is an attempt to fix the bug discussed in
>>> https://lkml.org/lkml/2014/3/4/218
>>>
>>> Since I am not really familiar with interrupts I am not sure if this is
>>> the right way to do it. I am looking forward to your comments.
>>>
>> Looks OK.
>
> I think a plain revert of Prabhakar patch would bring us in an "usual"
> situation where the drivers's ndo_open():
>
> - masks all interrupts bits at the Ethernet MAC level
> - calls request_irq()
> - unmask relevant interrupts bits at the Ethernet Mac level
>
> just in case some uncontrolled interrupt bit triggers an interrupt
> while the interface is down for instance...

I am fine with either solution and I will be happy to prepare a patch if we 
agree that we should revert the patch. What was the reason for commit 
6892b41d9701283085b655c6086fb57a5d63fa47 in the first place? Does it fix a 
problem?

Should the full commit 6892b41d9701283085b655c6086fb57a5d63fa47 be 
reverted? Actually it consists of two parts, the first part replaces 
request_irq with devm_request_irq and throws out free_irq, the second part 
replaces devm_request_mem_region/devm_ioremap with devm_ioremap_resource. 
The first part causes the problem. Shall we keep the second part or shall 
this be reverted as well?

Christian


>
> On a wider note, it would be good to get some tool to notify people
> that attempting to replace devm_request_irq() in a network driver's
> ndo_open() function is not going to produce the expected results as
> the two are not strictly identical.
> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
