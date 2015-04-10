From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Fri, 10 Apr 2015 17:04:31 +0200
Message-ID: <5527E67F.7010107@free.fr>
References: <5525571D.7060909@free.fr>	<5525658D.7000709@gmail.com>	<5526662C.8010509@free.fr>	<5526806E.5020309@zonque.org>	<55268EF3.7050301@free.fr>	<5526993F.1010304@free.fr>	<5526B608.2080504@gmail.com>	<5526CA87.2070204@free.fr>	<5526CC5A.1080504@gmail.com>	<5526D359.1050202@free.fr>	<CAOMZO5DhQnOtSN_bmh7JsCf=GsFats3pqpH4w+p1XWtAF=4LmQ@mail.gmail.com> <CAOMZO5BoYo_wvmxS0EN0M6CaLWk-rvCw6hpmmwvGNwAG=1vkMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Mack <daniel@zonque.org>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:12470 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933480AbbDJPEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 11:04:39 -0400
In-Reply-To: <CAOMZO5BoYo_wvmxS0EN0M6CaLWk-rvCw6hpmmwvGNwAG=1vkMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fabio Estevam wrote:
> Fabio Estevam wrote:
>> Mason wrote:
>>
>>> Am I the only having problems with the AR8035? :-(
>>>
>>> The standard driver works for everyone but me?
>>
>> Works well on a imx6q-hummingboard:
>>
>> fec 2188000.ethernet eth0: Freescale FEC PHY driver [Atheros 8035
>> ethernet] (mii_bus:phy_addr=2188000.ethernet:00, irq=-1)

Could you tell me the value of BMCR on entry and exit of phy_init_hw?

> Forgot to point out that we also have a 8035 fixup in
> arch/arm/mach-imx/mach-imx6q.c. Search for ar8035_phy_fixup().

Thanks for the pointer.

Freescale's ar8031_phy_fixup() is almost the same as U-boot's ar8035_config()
The only difference is one extra sanitizing instruction: val &= 0xffe3;

What's the point of masking bits 3 and 4, when they are set by the
next instruction:

   val &= 0xffe3;
   val |= 0x18;

The result of these two operations is
bit2=0 bit3=1 bit4=1 other=unchanged

Bit 2 is undocumented, why does Freescale set it to 0?

The tx clock delay is already done in the generic driver.
Do you know why it is necessary? Why not rx clock delay also?

I'll give the "disable SmartEEE" fixup a try.

Not sure why they reset the POWER_DOWN bit? It's cleared by both
HW and SW resets.

Regards.
