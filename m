From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 17:13:58 +0100
Message-ID: <4F0C63C6.5080305@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com> <4F0C31F1.20908@essax.com> <4F0C4EA8.7060002@grandegger.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.essax.com ([80.71.48.244]:51291 "EHLO mail.essax.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756527Ab2AJQOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 11:14:09 -0500
In-Reply-To: <4F0C4EA8.7060002@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Wolfgang,

> On 01/10/2012 01:41 PM, Wolfgang Zarre wrote:
>> Hello David,
>>>
>>>> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>>>>                             int reg, u8 val)
>>>>     {
>>>>         unsigned long base = (unsigned long)priv->reg_base;
>>>> +    unsigned long flags;
>>>>
>>>> +    spin_lock_irqsave(&outb_lock, flags);
>>>>         outb(reg, base);
>>>>         outb(val, base + 1);
>>>> +    spin_unlock_irqrestore(&outb_lock, flags);
>>>
>>> Is there a 'read_reg_indirect' function??
>>
>> Yes, there is.
>>
>>> If so it also needs to use the same mutex.
>>
>> Actually, I don't think that we have a problem with mutex
>> beside that it's using just one inb() statement but having
>> for sure with an interrupt between both outb() statements which
>> seems to be critical for the cc770.
>
> But the indirect read function also sets the address register before
> reading the data using inb(). This sequence should also not be
> interrupted and therefore we need to synchronize. For the indirect
> access of the SJA1000 we also need to add spinlocks. Wonder why nobody
> complained so far.

So, if I understand correct that means that inb() can be interrupted between
setting the address and reading. If this is the case then yes, we need
spinlock if this is not the case then IMHO we wouldn't need or am I wrong?



>
> Wolfgang.
>

Wolfgang
