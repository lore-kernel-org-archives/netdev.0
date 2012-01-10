From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 13:41:21 +0100
Message-ID: <4F0C31F1.20908@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,
>
>> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>>    						int reg, u8 val)
>>    {
>>    	unsigned long base = (unsigned long)priv->reg_base;
>> +	unsigned long flags;
>>
>> +	spin_lock_irqsave(&outb_lock, flags);
>>    	outb(reg, base);
>>    	outb(val, base + 1);
>> +	spin_unlock_irqrestore(&outb_lock, flags);	
>
> Is there a 'read_reg_indirect' function??

Yes, there is.

> If so it also needs to use the same mutex.

Actually, I don't think that we have a problem with mutex
beside that it's using just one inb() statement but having
for sure with an interrupt between both outb() statements which
seems to be critical for the cc770.

However, if inb() or outb() can be interrupted then it would be
an issue.

> I'd double check all references to the 'reg_base' field.
>
> 	David
>
>

Wolfgang
