From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: randconfig build error with next-20141001, in drivers/i2c/algos/i2c-algo-bit.c
Date: Tue, 07 Oct 2014 10:58:25 +0200
Message-ID: <5433AB31.9090603@hartkopp.net>
References: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com> <542C8D93.8090008@infradead.org> <54324D68.6070309@hartkopp.net> <5432C8C6.7060506@infradead.org> <5432D3E6.9020805@hartkopp.net> <5432DAE8.5030509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-i2c@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5432DAE8.5030509@infradead.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2014 08:09 PM, Randy Dunlap wrote:
> On 10/06/14 10:39, Oliver Hartkopp wrote:

>> AFAICS there is 'just' a style problem as 'configs should not enable entire
>> subsystems'. But it finally is a correct and valid Kconfig, right?
> 
> Yes, right.

(..)

> In the unlikely case that I2C is not enabled, the user should have to enable
> it instead of a solitary driver enabling it.  IOW, if a subsystem is disabled,
> the user probably wanted it that way and a single driver should not override
> that setting.

Due to the fact that a change to 'depends on I2C' would make the config option
invisible (and therefore not selectable) in the case I2C was (unlikely)
disabled I would finally vote to leave it as-is.

The current Kconfig entry already contains a description that points to the
requirement to have I2C and I2C_ALGOBIT to be enabled to compile this driver:

config CAN_PEAK_PCIEC
	bool "PEAK PCAN-ExpressCard Cards"
	depends on CAN_PEAK_PCI
	select I2C
	select I2C_ALGOBIT
	default y
	---help---
	  Say Y here if you want to use a PCAN-ExpressCard from PEAK-System
	  Technik. This will also automatically select I2C and I2C_ALGO
	  configuration options.

AFAIK the PEAK PCAN-ExpressCard is usually used in x86 architecture Laptops,
so it's near to an academic discussion as x86 usually selects I2C ;-)

@Stephane: When updating the help text to introduce the PCAN-ExpressCard 34
support anyway you might probably add some more information *why* the I2C
support is needed (for CAN transceiver settings and status LED).

And /s/I2C_ALGO/I2C_ALGOBIT/ :-)

Tnx & best regards,
Oliver
