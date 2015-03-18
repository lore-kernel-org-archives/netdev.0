From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: fix endian code for avr32
Date: Wed, 18 Mar 2015 13:27:15 +0100
Message-ID: <55096F23.10302@atmel.com>
References: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk> <20150318122538.GA19497@samfundet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@lists.codethink.co.uk>,
	Linux Networking List <netdev@vger.kernel.org>,
	Arun Chandran <achandran@mvista.com>,
	"Haavard Skinnemoen" <hskinnemoen@gmail.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>
To: Hans-Christian Egtvedt <egtvedt@samfundet.no>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150318122538.GA19497@samfundet.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/03/2015 13:25, Hans-Christian Egtvedt a =E9crit :
> Around Wed 18 Mar 2015 10:57:27 +0000 or thereabout, Ben Dooks wrote:
>> [note this has yet to be compile tested on avr32]
>>
>=20
> Compiles fine without warnings.
>=20
>> The changes to run the macb driver in 29af05aeb98e ("net: macb:
>> Add big endian CPU support") to support big endian operation on
>> ARM may not work on AVR32 which already is naturally big endian
>> architecture (and the driver already works here).
>=20
> The 29af05aeb98e will brick the macb driver for AVR32, as readZ_relax=
ed
> translates to readZ calls, which turns into le_to_cpu reads.
>=20
>> In this case  the readl/writel relaxed will do the opposite of __raw
>> accesors which arleady work. Add an indirection of cdneth_ prefixed
>> accesors which are changed as necessary. Also do not issue the DMA
>> descritpor endian fetch configuration for AVR32.
>>
>> From discussions with Arnd Bergman, the following fix changes the us=
e
>> of readl_relaxed and writel_relaxed with a version that can be put
>> back to __raw_readl/__raw_writel for the CONFIG_AVR32 case (and also
>> remove the change to the DMA descriptor endian).
>=20
> Thank you for spotting this.
>=20
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>> Reported-by: Arnd Bergmann <arnd@arndb.de>
>=20
> Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

>> --
>> CC: Linux Networking List <netdev@vger.kernel.org>
>> CC: Arun Chandran <achandran@mvista.com>
>> CC: Haavard Skinnemoen <hskinnemoen@gmail.com>
>> CC: Hans-Christian Egtvedt <egtvedt@samfundet.no>
>> CC: Linux Kernel List <linux-kernel@vger.kernel.org>
>> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
>>  drivers/net/ethernet/cadence/macb.h | 20 ++++++++++++++------
>>  2 files changed, 21 insertions(+), 13 deletions(-)
>=20
> <snipp diff>
>=20


--=20
Nicolas Ferre
