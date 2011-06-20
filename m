From: Jon Mason <jon.mason@myri.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Mon, 20 Jun 2011 10:23:07 -0500
Message-ID: <BANLkTikDM4OWOb=f5qdyWhZu4se4CWHYfw@mail.gmail.com>
References: <1306956602.32125.28.camel@Joe-Laptop>
	<1306957998.3076.18.camel@jtkirshe-MOBL1>
	<1306958478.32125.32.camel@Joe-Laptop>
	<BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	<1308186619.12377.23.camel@Joe-Laptop>
	<BANLkTin0QzAscKcN0Yw6rc7fUh5d5q143w@mail.gmail.com>
	<1308535174.22851.26.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Andrew Gallatin <gallatin@myri.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61393 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab1FTPXH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 11:23:07 -0400
Received: by mail-iy0-f174.google.com with SMTP id 12so2050369iyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 08:23:07 -0700 (PDT)
In-Reply-To: <1308535174.22851.26.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]
>> > commit 83df87d655e25119eafaeb4225bc5eedaa82c6e0
>> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> > Date: =A0 Fri May 13 02:24:46 2011 -0700
>> >
>> > =A0 =A0myri*: Move the Myricom drivers
>> >
>> > =A0 =A0Move the Myricom drivers into drivers/net/ethernet/myricom/=
 and
>> make
>> > =A0 =A0the necessary Kconfig and Makefile changes.
>> >
>> > =A0 =A0CC: Andrew Gallatin <gallatin@myri.com>
>> > =A0 =A0CC: Brice Goglin <brice@myri.com>
>> > =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> >
>> > =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> > =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0| =A0 35
>> -------------
>> > =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 | =A0 =A03 -
>> > =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A01 +
>> > =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A01 +
>> > =A0drivers/net/ethernet/myricom/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 51
>> ++++++++++++++++++++
>> > =A0drivers/net/ethernet/myricom/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A06 ++
>> > =A0.../net/{ =3D> ethernet/myricom}/myri10ge/Makefile =A0 | =A0 =A0=
0
>> > =A0.../net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c | =A0 =A00
>> > =A0.../{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.h | =A0 =A00
>> > =A0.../myricom}/myri10ge/myri10ge_mcp_gen_header.h =A0 =A0| =A0 =A0=
0
>> > =A0drivers/net/{ =3D> ethernet/myricom}/myri_sbus.c =A0 =A0 | =A0 =
=A00
>> > =A0drivers/net/{ =3D> ethernet/myricom}/myri_sbus.h =A0 =A0 | =A0 =
=A00
>>
>> /me puts on Myricom hat
>>
>> I believe we want to put the driver above in the sbus/legacy
>> directory. =A0Better yet, move this driver to /dev/null. =A0There is=
 no
>> possibility of ethernet mode on this adapter, so it's Myrinet only.
>> It won't inter-op with modern versions of Myrinet, and thus can only
>> work with legacy adapters. =A0There are no drivers for the PCI versi=
on
>> of this adapter, so it only can work on ~15year old hardware. =A0It'=
s
>> long in the tooth, let's take it to the knackers.
>>
>> Thanks,
>> Jon
>
> That sounds good. =A0Since I am not the maintainer or author of the
> driver, I think such a move should come from Myricom. =A0I can drop t=
he
> move of myri_sbus.[ch] from my patches to organize the driver/net/
> directory.


I'll submit a patch shortly to remove it.  Assuming that it will be
rejected, I'd recommend putting myri_sbus.* into
 drivers/net/myrinet/
similar to how you have an ethernet directory.

Thanks,
Jon
