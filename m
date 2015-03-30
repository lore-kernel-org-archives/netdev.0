From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 3/4] net/macb: fix capabilities configuration
Date: Mon, 30 Mar 2015 08:33:59 +0200
Message-ID: <5518EE57.8050808@atmel.com>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>	<bd7194896b4e4517a7675ae02fe7bed01f19a02d.1427469791.git.nicolas.ferre@atmel.com> <20150328000235.30337361@bbrezillon>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>, <punnaia@xilinx.com>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150328000235.30337361@bbrezillon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/03/2015 00:02, Boris Brezillon a =E9crit :
> Hi Nicolas,
>=20
> On Fri, 27 Mar 2015 16:34:11 +0100
> Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>=20
>> Capabilities configuration by macb_configure_caps() was moved far to=
o late by
>> 421d9df0628b (net/macb: merge at91_ether driver into macb driver) wh=
ich would
>> lead to badly configured hardware.
>=20
> Indeed, the macb_configure_caps function is called a bit too late,
> but ...
>=20
>> So, move this function to early probe and modify its prototype to re=
-gain its
>> original behavior.
>> DT data retrieval is also moved to simplify the probe code flow.
>=20
> ... I'm not happy with these changes.
> I tried to keep  specific init steps of macb and at91_ether separated
> and you're moving macb_configure_caps call (not required on at91_ethe=
r
> HW) into macb_probe (the common probe part).

Well, this function is about configuring the capabilities of the
hardware both from the configuration registers and the device tree
entries (this last source applies to all flavors of hardware).

I only see advantages to set these flags early (Cf. above).

> How about moving macb_configure_caps a bit earlier in the macb_init
> function [1] ?

No, it won't be sufficient. The very first function needing the
capabilities set is macb_get_hwaddr() which is pretty early in macb_pro=
be().


Bye,

> Best Regards,
>=20
> Boris
>=20
> [1]http://code.bulix.org/8gyi6b-88141
>=20


--=20
Nicolas Ferre
