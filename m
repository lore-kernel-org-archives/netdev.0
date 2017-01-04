From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH repost net-next] dsa: mv88e6xxx: Optimise atu_get
Date: Wed, 4 Jan 2017 13:27:00 -0800
Message-ID: <af9a7011-1258-dc87-af59-2ceac4388f83@gmail.com>
References: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
 <20170104.161103.175830630875484681.davem@davemloft.net>
 <20170104211957.GD4229@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: volodymyr.bendiuga@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33091 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761095AbdADV1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 16:27:02 -0500
Received: by mail-pg0-f65.google.com with SMTP id g1so38344073pgn.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 13:27:02 -0800 (PST)
In-Reply-To: <20170104211957.GD4229@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 01:19 PM, Andrew Lunn wrote:
> On Wed, Jan 04, 2017 at 04:11:03PM -0500, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Wed,  4 Jan 2017 19:56:24 +0100
>>
>>> +static inline u64 ether_addr_to_u64(const u8 *addr)
>>> +{
>>> +	u64 u = 0;
>>> +	int i;
>>> +
>>> +	for (i = 0; i < ETH_ALEN; i++)
>>> +		u = u << 8 | addr[i];
>>> +
>>> +	return u;
>>> +}
>>  ...
>>> +static inline void u64_to_ether_addr(u64 u, u8 *addr)
>>> +{
>>> +	int i;
>>> +
>>> +	for (i = ETH_ALEN - 1; i >= 0; i--) {
>>> +		addr[i] = u & 0xff;
>>> +		u = u >> 8;
>>> +	}
>>> +}
>>
>> I think these two routines behave differently on big vs little
>> endian.  And I doubt this was your intention.
> 
> I don't have a big endian system to test on.

You could build the driver for e.g: a MIPS Malta board and use the
qemu-system-mips to validate this, there could be a way to do that on
ARM too although it's a different kind of BE (BE8 vs. BE32) AFAIR.

> 
> I tried to avoid the usual pitfalls. I don't cast a collection of
> bytes to a u64, which i know has no chance of working. Accessing a MAC
> address as a byte array should be endian safe. The shift operation
> should also be endian safe.
> 
> What exactly do you think will behave differently?
> 
>      Andrew
> 


-- 
Florian
