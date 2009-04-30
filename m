From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Porting the ibm_newemac driver to use phylib (and other PHY/MAC
	questions)
Date: Thu, 30 Apr 2009 09:11:24 -0600
Message-ID: <fa686aa40904300811u41e94972offfd75520636bb02@mail.gmail.com>
References: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
	<625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
	<f73f7ab80904201710m57472291yf7ff86760977b8e8@mail.gmail.com>
	<1240388476.17445.10.camel@pasglop> <f73f7ab80904300804j1f847b70ha0fe3cda07249110@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:60758 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbZD3PLp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 11:11:45 -0400
In-Reply-To: <f73f7ab80904300804j1f847b70ha0fe3cda07249110@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 9:04 AM, Kyle Moffett <kyle@moffetthome.net> wr=
ote:
> On Wed, Apr 22, 2009 at 4:21 AM, Benjamin Herrenschmidt
> <benh@kernel.crashing.org> wrote:
>> On Mon, 2009-04-20 at 20:10 -0400, Kyle Moffett wrote:
>>> > IIRC, Ben had some issues with how phylib and the EMAC would need=
 to
>>> > interact. =A0Not sure if he has those written down somewhere or n=
ot.
>>> > (CC'd).
>>>
>>> Hmm, yeah, I'd be interested to see those. =A0There's enough simila=
r
>>> between phylib and the EMAC and sungem drivers that I'm considering=
 a
>>> series of somewhat-mechanical patches to make EMAC and sungem use t=
he
>>> "struct phy_device" and "struct mii_bus" from phylib, possibly
>>> abstracting out some helper functions along the way.
>>
>> Yup, emac and sungem predate phylib.
>>
>> I had a quick look at what it would take to port at least emac over,=
 the
>> main issue was that I want to be able to sleep (ie, take a mutex) in=
 my
>> mdio read/write functions, and back then, phylib wouldn't let me do =
that
>> due to spinlock and timer/softirq usage.
>
> Ok, I've made some progress in the port, but right now I'm trying to
> puzzle out what the "gpcs" bits in the code are. =A0From the few
> publicly available docs and some mailing list posts, the gpcs address
> appears to be some kind of integrated virtual PHY used when 460GT-ish
> chips are communicating via an SGMII bus. =A0My current plan of actio=
n
> is to separate the "gpcs" out into a separate PHY device controlled b=
y
> the emac code.
>
> I'm also curious about the intent of the "mdio_instance" pointer (IE:
> the "mdio-device" property). =A0Is that used when all the PHY devices
> are attached to the MDIO bus of only one of the (multiple) emac
> devices? =A0Or is that for when two emac chipsets are connected to th=
e
> same MDIO bus wire? =A0(or both?) =A0What keeps the emac_instance poi=
nted
> to by the "mdio_instance" from going away while the other emac chipse=
t
> is using it?
>
> In either case, I plan to have the device actually holding the MDIO
> bus run the mdiobus_alloc() and mdiobus_register() functions, then th=
e
> other emac instance will simply take a reference to that MDIO bus
> (which would also pin down the emac instance that owns it).

Just a heads up Kyle; there are changes queued in the netdev tree
which add OF helpers for MDIO bus drivers and MAC drivers.  See here:

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3D8bc487d150b939e69830c39322df4ee486efe381

and here is an example of a driver change:

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3D1dd2d06c0459a2f1bffc56765e3cc57427818867

Cheers,
g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
