From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH V3] net: ezchip: adapt driver to little endian
 architecture
Date: Sat, 12 Mar 2016 10:53:23 +0530
Message-ID: <56E3A7CB.2020001@synopsys.com>
References: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
 <20160303.172043.676796529681577242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <Alexey.Brodkin@synopsys.com>,
	<noamc@ezchip.com>, <talz@ezchip.com>, <arnd@arndb.de>,
	arcml <linux-snps-arc@lists.infradead.org>
To: <Lada.Trimasova@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:54709 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbcCLFXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 00:23:44 -0500
In-Reply-To: <20160303.172043.676796529681577242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 March 2016 03:50 AM, David Miller wrote:
> From: Lada Trimasova <Lada.Trimasova@synopsys.com>
> Date: Thu,  3 Mar 2016 17:07:46 +0300
> 
>> Since ezchip network driver is written with big endian EZChip platform it
>> is necessary to add support for little endian architecture.
>>
>> The first issue is that the order of the bits in a bit field is
>> implementation specific. So all the bit fields are removed.
>> Named constants are used to access necessary fields.
>>
>> And the second one is that network byte order is big endian.
>> For example, data on ethernet is transmitted with most-significant
>> octet (byte) first. So in case of little endian architecture
>> it is important to swap data byte order when we read it from
>> register. In case of unaligned access we can use "get_unaligned_be32"
>> and in other case we can use function "ioread32_rep" which reads all
>> data from register and works either with little endian or big endian
>> architecture.
>>
>> And then when we are going to write data to register we need to restore
>> byte order using the function "put_unaligned_be32" in case of
>> unaligned access and in other case "iowrite32_rep".
>>
>> The last little fix is a space between type and pointer to observe
>> coding style.
>>
>> Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>
> 
> Applied to net-next, thanks.
> 

@Lada, could you provide the corresponding arch/arc/{boot/dts,configs}/ updates so
we can switch over to this device-model/driver for OSCI platform for 4.6.

Thx,
-Vineet
