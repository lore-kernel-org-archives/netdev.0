From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 15:43:52 +0100
Message-ID: <4F0C4EA8.7060002@grandegger.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com> <4F0C31F1.20908@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ngcobalt02.manitu.net ([217.11.48.102]:52219 "EHLO
	ngcobalt02.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab2AJOoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 09:44:08 -0500
In-Reply-To: <4F0C31F1.20908@essax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2012 01:41 PM, Wolfgang Zarre wrote:
> Hello David,
>>
>>> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>>>                            int reg, u8 val)
>>>    {
>>>        unsigned long base = (unsigned long)priv->reg_base;
>>> +    unsigned long flags;
>>>
>>> +    spin_lock_irqsave(&outb_lock, flags);
>>>        outb(reg, base);
>>>        outb(val, base + 1);
>>> +    spin_unlock_irqrestore(&outb_lock, flags);   
>>
>> Is there a 'read_reg_indirect' function??
> 
> Yes, there is.
> 
>> If so it also needs to use the same mutex.
> 
> Actually, I don't think that we have a problem with mutex
> beside that it's using just one inb() statement but having
> for sure with an interrupt between both outb() statements which
> seems to be critical for the cc770.

But the indirect read function also sets the address register before
reading the data using inb(). This sequence should also not be
interrupted and therefore we need to synchronize. For the indirect
access of the SJA1000 we also need to add spinlocks. Wonder why nobody
complained so far.

Wolfgang.
