From: Timur Tabi <timur@freescale.com>
Subject: Re: Kconfig warnings on latest GIT
Date: Tue, 08 May 2007 15:11:52 -0500
Message-ID: <4640D988.1040504@freescale.com>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:42364 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967846AbXEHUMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 16:12:21 -0400
In-Reply-To: <20070508143127.38fafa3c.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> On Tue, 8 May 2007 00:04:14 +0300
> Ismail D=F6nmez <ismail@pardus.org.tr> wrote:
>=20
>> drivers/net/Kconfig:2279:warning: 'select' used by config symbol 'UC=
C_GETH'=20
>> refers to undefined symbol 'UCC_FAST'
>=20
> looks like this introduces the error:
>=20
> commit 7d776cb596994219584257eb5956b87628e5deaf
> Author: Timur Tabi <timur@freescale.com>
> Date:   Mon Mar 12 15:40:27 2007 -0500
>=20
>     [POWERPC] QE: automatically select QE options

I have a dilemma, so I need help fixing this bug.

This particular patch is necessary because without it, selecting suppor=
t for the QE is too=20
complicated.

Background: The QUICC Engine (QE) is a microcontroller on some Freescal=
e CPUs that can=20
mimic a wide variety of devices.  It has multiple controllers (called U=
CCs), and each one=20
can be an ethernet device, or a UART, or an HDLC thingy, etc.  There's =
a QE library and a=20
bunch of other support code in the arch/powerpc directory, so the QE is=
 a powerpc-specific=20
device.  However, all of the drivers that use it are located in drivers=
/xxx.

This isn't a new problem.  The common solution is to define some interm=
ediate Kconfig=20
option, like UCC_FAST_TEMP in the driver's Kconfig.  Selecting UCC_FAST=
 will then also set=20
UCC_FAST_TEMP.  The device driver then depends on UCC_FAST_TEMP.

There's also a UCC_SLOW option with the same problem.

The dillema is that there is no single device driver class that depends=
 on UCC_FAST.=20
Currently, there's only one that uses UCC_FAST: the ucc_geth driver.  B=
ut I'm also working=20
on a UART driver.

So my question is: in which Kconfig do I define "UCC_FAST_TEMP" and "UC=
C_SLOW_TEMP"?  At=20
first I thought, just put it in drivers/Kconfig, but that Kconfig does =
nothing but=20
including other Kconfigs.  I believe that if I submit a patch that adds=
 "UCC_FAST_TEMP"=20
and "UCC_SLOW_TEMP" to drivers/Kconfig, it will be rejected.  Either th=
at, or I'll spend=20
six weeks trying to persuade everyone that it's a good idea.

Does anyone have any suggestions on how I can fix this?

--=20
Timur Tabi
Linux Kernel Developer @ Freescale
