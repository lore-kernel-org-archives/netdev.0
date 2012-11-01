From: "Cousson, Benoit" <b-cousson@ti.com>
Subject: Re: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes for
 AM33XX
Date: Thu, 1 Nov 2012 10:28:47 +0100
Message-ID: <509240CF.6060909@ti.com>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com> <1351498881-32482-6-git-send-email-hvaibhav@ti.com> <50914107.2090909@ti.com> <20121101074508.GA2637@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vaibhav Hiremath <hvaibhav@ti.com>, <netdev@vger.kernel.org>,
	<paul@pwsan.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:57904 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab2KAJ2x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 05:28:53 -0400
In-Reply-To: <20121101074508.GA2637@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/2012 8:45 AM, Richard Cochran wrote:
> On Wed, Oct 31, 2012 at 04:17:27PM +0100, Benoit Cousson wrote:
>>> +			compatible = "ti,cpsw";
>>> +			ti,hwmods = "cpgmac0";
>>> +			cpdma_channels = <8>;
>>> +			host_port_no = <0>;
>>> +			cpdma_reg_ofs = <0x800>;
>>> +			cpdma_sram_ofs = <0xa00>;
>>> +			ale_reg_ofs = <0xd00>;
>>> +			ale_entries = <1024>;
>>> +			host_port_reg_ofs = <0x108>;
>>> +			hw_stats_reg_ofs = <0x900>;
>>> +			bd_ram_ofs = <0x2000>;
>>> +			bd_ram_size = <0x2000>;
>>> +			no_bd_ram = <0>;
>>> +			rx_descs = <64>;
>>> +			mac_control = <0x20>;
>>
>> Do you have to store all these data in the DTS? Cannot it be in the driver?
>>
>> Do you expect to have several instance of the same IP with different
>> parameters here?
>
> As I understand it, there are only two different layouts for the CPSW,
> the one in the dm814x and the one in the am335x. So I think it would
> work to put only the version register offet in the DT, and the let the
> driver figure out the rest from there.

Yes, that's indeed better. We did that for other IPs already (GPIO, I2C...)

> But if TI is planning on reordering the registers with each new
> silicon revision, again and again, then it might make sense to keep
> the offsets in the DT.

Yeah, let's assume they will do a better job in the future.

All these offset registers information does belong to the driver, and 
even if the HW change a lot, I still rather hide that in the driver.
It will always be cleaner, most efficient, and will reduce the size if 
the blob.

> [ I really wonder why the hardware people think that reshuffling the
>    register layout constitutes an improvement. ]

I've been wondering that for ten years :-(
I'm always hoping it will be better some day.

Regards,
Benoit
