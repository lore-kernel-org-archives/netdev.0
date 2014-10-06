From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: randconfig build error with next-20141001, in drivers/i2c/algos/i2c-algo-bit.c
Date: Mon, 06 Oct 2014 09:52:22 -0700
Message-ID: <5432C8C6.7060506@infradead.org>
References: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com> <542C8D93.8090008@infradead.org> <54324D68.6070309@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next <linux-next@vger.kernel.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	linux-i2c@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <54324D68.6070309@hartkopp.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/14 01:06, Oliver Hartkopp wrote:
> Hello all,
>=20
> just to get it right:
>=20
> So far it looks like this in linux/drivers/net/can/sja1000/Kconfig
>=20
> config CAN_PEAK_PCIEC
>         bool "PEAK PCAN-ExpressCard Cards"
>         depends on CAN_PEAK_PCI
>         select I2C
>         select I2C_ALGOBIT
>=20
> If one would change the
>=20
>         select I2C
>=20
> into
>=20
>         depends on I2C
>=20
> IMHO the CAN_PEAK_PCIEC hardware would *only* be visible and selectab=
le when
> I2C was selected before (from anyone else?).

That is correct.

> So what it wrong on the current Kconfig entry?
> Is 'select' deprecated?

No, it's not deprecated.  It's just dangerous.  and driver configs shou=
ld not
enable entire subsystems via 'select'.

> Or did randconfig generate a configuration that would not be possible=
 by
> properly generating the config file with 'make menuconfig' ??

randconfig generated a config for another driver which causes a build e=
rror,
not for a CAN driver.  The CAN driver does not have a build error AFAIK=
=2E
Its Kconfig is just doing something with a very big & ugly stick.


> Please explain.
>=20
> Thanks,
> Oliver
>=20
> On 10/02/2014 01:26 AM, Randy Dunlap wrote:
>> On 10/01/14 14:37, Jim Davis wrote:
>>> Building with the attached random configuration file,
>>
>> Also:
>> warning: (CAN_PEAK_PCIEC && SFC && IGB && VIDEO_TW68 && DRM && FB_DD=
C && FB_VIA) selects I2C_ALGOBIT which has unmet direct dependencies (I=
2C)
>>
>>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92=
:
>>> drivers/i2c/algos/i2c-algo-bit.c:658:33: error: =91i2c_add_adapter=92
>>> undeclared (first use in this function)
>>>   return __i2c_bit_add_bus(adap, i2c_add_adapter);
>>>                                  ^
>>> drivers/i2c/algos/i2c-algo-bit.c:658:33: note: each undeclared
>>> identifier is reported only once for each function it appears in
>>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_number=
ed_bus=92:
>>> drivers/i2c/algos/i2c-algo-bit.c:664:33: error:
>>> =91i2c_add_numbered_adapter=92 undeclared (first use in this functi=
on)
>>>   return __i2c_bit_add_bus(adap, i2c_add_numbered_adapter);
>>>                                  ^
>>>   CC      net/openvswitch/actions.o
>>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92=
:
>>> drivers/i2c/algos/i2c-algo-bit.c:659:1: warning: control reaches en=
d of non-void
>>>  function [-Wreturn-type]
>>>  }
>>>  ^
>>> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_number=
ed_bus=92:
>>> drivers/i2c/algos/i2c-algo-bit.c:665:1: warning: control reaches en=
d of non-void
>>>  function [-Wreturn-type]
>>>  }
>>>  ^
>>> make[3]: *** [drivers/i2c/algos/i2c-algo-bit.o] Error 1
>>
>> In drivers/media/pci/tw68/Kconfig, VIDEO_TW68 should depend on I2C i=
n order
>> to make it safe to select I2C_ALGOBIT.
>>
>> In drivers/net/can/sja1000/Kconfig, CAN_PEAK_PCIEC should depend on =
I2C
>> instead of selecting I2C (and change the help text).


--=20
~Randy
