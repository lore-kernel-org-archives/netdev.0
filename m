From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: randconfig build error with next-20141001, in drivers/i2c/algos/i2c-algo-bit.c
Date: Mon, 06 Oct 2014 10:06:00 +0200
Message-ID: <54324D68.6070309@hartkopp.net>
References: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com> <542C8D93.8090008@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next <linux-next@vger.kernel.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	linux-i2c@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>,
	Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542C8D93.8090008@infradead.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

just to get it right:

So far it looks like this in linux/drivers/net/can/sja1000/Kconfig

config CAN_PEAK_PCIEC
        bool "PEAK PCAN-ExpressCard Cards"
        depends on CAN_PEAK_PCI
        select I2C
        select I2C_ALGOBIT

If one would change the

        select I2C

into

        depends on I2C

IMHO the CAN_PEAK_PCIEC hardware would *only* be visible and selectable=
 when
I2C was selected before (from anyone else?).

So what it wrong on the current Kconfig entry?
Is 'select' deprecated?

Or did randconfig generate a configuration that would not be possible b=
y
properly generating the config file with 'make menuconfig' ??

Please explain.

Thanks,
Oliver

On 10/02/2014 01:26 AM, Randy Dunlap wrote:
> On 10/01/14 14:37, Jim Davis wrote:
>> Building with the attached random configuration file,
>=20
> Also:
> warning: (CAN_PEAK_PCIEC && SFC && IGB && VIDEO_TW68 && DRM && FB_DDC=
 && FB_VIA) selects I2C_ALGOBIT which has unmet direct dependencies (I2=
C)
>=20
>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92:
>> drivers/i2c/algos/i2c-algo-bit.c:658:33: error: =91i2c_add_adapter=92
>> undeclared (first use in this function)
>>   return __i2c_bit_add_bus(adap, i2c_add_adapter);
>>                                  ^
>> drivers/i2c/algos/i2c-algo-bit.c:658:33: note: each undeclared
>> identifier is reported only once for each function it appears in
>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_numbere=
d_bus=92:
>> drivers/i2c/algos/i2c-algo-bit.c:664:33: error:
>> =91i2c_add_numbered_adapter=92 undeclared (first use in this functio=
n)
>>   return __i2c_bit_add_bus(adap, i2c_add_numbered_adapter);
>>                                  ^
>>   CC      net/openvswitch/actions.o
>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92:
>> drivers/i2c/algos/i2c-algo-bit.c:659:1: warning: control reaches end=
 of non-void
>>  function [-Wreturn-type]
>>  }
>>  ^
>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_numbere=
d_bus=92:
>> drivers/i2c/algos/i2c-algo-bit.c:665:1: warning: control reaches end=
 of non-void
>>  function [-Wreturn-type]
>>  }
>>  ^
>> make[3]: *** [drivers/i2c/algos/i2c-algo-bit.o] Error 1
>=20
> In drivers/media/pci/tw68/Kconfig, VIDEO_TW68 should depend on I2C in=
 order
> to make it safe to select I2C_ALGOBIT.
>=20
> In drivers/net/can/sja1000/Kconfig, CAN_PEAK_PCIEC should depend on I=
2C
> instead of selecting I2C (and change the help text).
>=20
>=20
