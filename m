From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: randconfig build error with next-20141001, in drivers/i2c/algos/i2c-algo-bit.c
Date: Wed, 01 Oct 2014 16:26:11 -0700
Message-ID: <542C8D93.8090008@infradead.org>
References: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, wsa@the-dreams.de,
	khali@linux-fr.org, Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-i2c@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org,
	linux-media <linux-media@vger.kernel.org>,
	Hans Verkuil <hverkuil@xs4all.nl>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhiL1y9aeLeJjpd_1DtzOG_oyoPg7XsTPJ9G-XY5G2DfCQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/01/14 14:37, Jim Davis wrote:
> Building with the attached random configuration file,

Also:
warning: (CAN_PEAK_PCIEC && SFC && IGB && VIDEO_TW68 && DRM && FB_DDC &=
& FB_VIA) selects I2C_ALGOBIT which has unmet direct dependencies (I2C)

> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92:
> drivers/i2c/algos/i2c-algo-bit.c:658:33: error: =91i2c_add_adapter=92
> undeclared (first use in this function)
>   return __i2c_bit_add_bus(adap, i2c_add_adapter);
>                                  ^
> drivers/i2c/algos/i2c-algo-bit.c:658:33: note: each undeclared
> identifier is reported only once for each function it appears in
> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_numbered=
_bus=92:
> drivers/i2c/algos/i2c-algo-bit.c:664:33: error:
> =91i2c_add_numbered_adapter=92 undeclared (first use in this function=
)
>   return __i2c_bit_add_bus(adap, i2c_add_numbered_adapter);
>                                  ^
>   CC      net/openvswitch/actions.o
> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_bus=92:
> drivers/i2c/algos/i2c-algo-bit.c:659:1: warning: control reaches end =
of non-void
>  function [-Wreturn-type]
>  }
>  ^
> drivers/i2c/algos/i2c-algo-bit.c: In function =91i2c_bit_add_numbered=
_bus=92:
> drivers/i2c/algos/i2c-algo-bit.c:665:1: warning: control reaches end =
of non-void
>  function [-Wreturn-type]
>  }
>  ^
> make[3]: *** [drivers/i2c/algos/i2c-algo-bit.o] Error 1

In drivers/media/pci/tw68/Kconfig, VIDEO_TW68 should depend on I2C in o=
rder
to make it safe to select I2C_ALGOBIT.

In drivers/net/can/sja1000/Kconfig, CAN_PEAK_PCIEC should depend on I2C
instead of selecting I2C (and change the help text).


--=20
~Randy
