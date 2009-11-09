From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: net-next section mismatch(es)
Date: Sun, 08 Nov 2009 21:01:32 -0500
Message-ID: <4AF777FC.4080805@gmail.com>
References: <4AF6D1F5.80307@gmail.com> <20091108.163527.185100796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:53930 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbZKICB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 21:01:29 -0500
Received: by ywh40 with SMTP id 40so2227661ywh.33
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2009 18:01:35 -0800 (PST)
In-Reply-To: <20091108.163527.185100796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
>> I remember compiling it once with that option, and not finding
>> anything
>> wrong in my code, but I'm wondering how it took a great leap?
>=20
> Well, type 'make CONFIG_DEBUG_SECTION_MISMATCH=3Dy' as the message
> says, in order to find out.
>=20
Hardly worth the time, as 'make modules' doesn't compile today:

/home/administer/net-next-2.6/drivers/staging/android/logger.c: In func=
tion =91logger_read=92:
/home/administer/net-next-2.6/drivers/staging/android/logger.c:165: err=
or: =91TASK_INTERRUPTIBLE=92 undeclared (first use in this function)
/home/administer/net-next-2.6/drivers/staging/android/logger.c:165: err=
or: (Each undeclared identifier is reported only once
/home/administer/net-next-2.6/drivers/staging/android/logger.c:165: err=
or: for each function it appears in.)
/home/administer/net-next-2.6/drivers/staging/android/logger.c:178: err=
or: implicit declaration of function =91signal_pending=92
/home/administer/net-next-2.6/drivers/staging/android/logger.c:183: err=
or: implicit declaration of function =91schedule=92
/home/administer/net-next-2.6/drivers/staging/android/logger.c: In func=
tion =91logger_aio_write=92:
/home/administer/net-next-2.6/drivers/staging/android/logger.c:325: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:333: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:334: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:337: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:360: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:363: err=
or: dereferencing pointer to incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:370: err=
or: increment of pointer to unknown structure
/home/administer/net-next-2.6/drivers/staging/android/logger.c:370: err=
or: arithmetic on pointer to an incomplete type
/home/administer/net-next-2.6/drivers/staging/android/logger.c:377: err=
or: =91TASK_INTERRUPTIBLE=92 undeclared (first use in this function)
make[4]: *** [drivers/staging/android/logger.o] Error 1
make[3]: *** [drivers/staging/android] Error 2
make[2]: *** [drivers/staging] Error 2
make[2]: *** Waiting for unfinished jobs....


But I did it with 'make vmlinux' anyway, still makes no sense to me:

/home/administer/net-next-2.6/arch/x86/include/asm/string_32.h:74: warn=
ing: array subscript is above array bounds
WARNING: drivers/acpi/processor.o(.text+0xa88): Section mismatch in ref=
erence from the function acpi_processor_add() to the function .cpuinit.=
text:acpi_processor_power_init()
The function acpi_processor_add() references
the function __cpuinit acpi_processor_power_init().
This is often because acpi_processor_add lacks a __cpuinit
annotation or the annotation of acpi_processor_power_init is wrong.

WARNING: drivers/acpi/built-in.o(.text+0x21f24): Section mismatch in re=
ference from the function acpi_processor_add() to the function .cpuinit=
=2Etext:acpi_processor_power_init()
The function acpi_processor_add() references
the function __cpuinit acpi_processor_power_init().
This is often because acpi_processor_add lacks a __cpuinit
annotation or the annotation of acpi_processor_power_init is wrong.

/home/administer/net-next-2.6/include/linux/mca-legacy.h:12:2: warning:=
 #warning "MCA legacy - please move your driver to the new sysfs api"
WARNING: drivers/net/phy/built-in.o(.devexit.text+0x13): Section mismat=
ch in reference from the function mdio_gpio_bus_destroy() to the functi=
on .devinit.text:mdio_gpio_bus_deinit()
The function __devexit mdio_gpio_bus_destroy() references
a function __devinit mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function
uses functionality in the init path.
The fix is often to remove the __devinit annotation of
mdio_gpio_bus_deinit() so it may be used outside an init section.

WARNING: drivers/net/built-in.o(.devexit.text+0x13): Section mismatch i=
n reference from the function mdio_gpio_bus_destroy() to the function .=
devinit.text:mdio_gpio_bus_deinit()
The function __devexit mdio_gpio_bus_destroy() references
a function __devinit mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function
uses functionality in the init path.
The fix is often to remove the __devinit annotation of
mdio_gpio_bus_deinit() so it may be used outside an init section.

/home/administer/net-next-2.6/arch/x86/include/asm/string_32.h:74: warn=
ing: array subscript is above array bounds
WARNING: drivers/built-in.o(.text+0x48274): Section mismatch in referen=
ce from the function acpi_processor_add() to the function .cpuinit.text=
:acpi_processor_power_init()
The function acpi_processor_add() references
the function __cpuinit acpi_processor_power_init().
This is often because acpi_processor_add lacks a __cpuinit
annotation or the annotation of acpi_processor_power_init is wrong.

WARNING: drivers/built-in.o(.devexit.text+0x38c): Section mismatch in r=
eference from the function mdio_gpio_bus_destroy() to the function .dev=
init.text:mdio_gpio_bus_deinit()
The function __devexit mdio_gpio_bus_destroy() references
a function __devinit mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function
uses functionality in the init path.
The fix is often to remove the __devinit annotation of
mdio_gpio_bus_deinit() so it may be used outside an init section.

WARNING: vmlinux.o(.text+0x27c824): Section mismatch in reference from =
the function acpi_processor_add() to the function .cpuinit.text:acpi_pr=
ocessor_power_init()
The function acpi_processor_add() references
the function __cpuinit acpi_processor_power_init().
This is often because acpi_processor_add lacks a __cpuinit
annotation or the annotation of acpi_processor_power_init is wrong.

WARNING: vmlinux.o(.text+0x2c8469): Section mismatch in reference from =
the function twl4030_sih_setup() to the function .init.text:set_irq_nop=
robe()
The function twl4030_sih_setup() references
the function __init set_irq_noprobe().
This is often because twl4030_sih_setup lacks a __init
annotation or the annotation of set_irq_noprobe is wrong.

WARNING: vmlinux.o(.text+0x2c8581): Section mismatch in reference from =
the function twl_init_irq() to the function .init.text:set_irq_noprobe(=
)
The function twl_init_irq() references
the function __init set_irq_noprobe().
This is often because twl_init_irq lacks a __init
annotation or the annotation of set_irq_noprobe is wrong.

WARNING: vmlinux.o(.devexit.text+0x3e1): Section mismatch in reference =
from the function mdio_gpio_bus_destroy() to the function .devinit.text=
:mdio_gpio_bus_deinit()
The function __devexit mdio_gpio_bus_destroy() references
a function __devinit mdio_gpio_bus_deinit().
This is often seen when error handling in the exit function
uses functionality in the init path.
The fix is often to remove the __devinit annotation of
mdio_gpio_bus_deinit() so it may be used outside an init section.



