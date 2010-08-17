From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Tue, 17 Aug 2010 12:37:02 -0700
Message-ID: <20100817123702.3d09a35b@nehalam>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
	<20100812120044.5b1880ad@s6510>
	<20100812121600.2e971e66@s6510>
	<AANLkTinM2m-dK2FYw5VBi3eBAhBRrrzZ+vH5aCtDoDVS@mail.gmail.com>
	<20100812151819.282636fe@s6510>
	<AANLkTimWmJ5mTOswT8oJx7MXckzDWcSySZdAu6HZb6r7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51610 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010Ab0HQThF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 15:37:05 -0400
In-Reply-To: <AANLkTimWmJ5mTOswT8oJx7MXckzDWcSySZdAu6HZb6r7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 13:31:13 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> > The status values indicate that the GMAC (frame parser) got a reaso=
nable
> > size frame but the DMA merged frames together. This indicates a tim=
ing
> > problem. There are some bits which even with NDA programmers manual=
 doesn't
> > help with. The Linux driver expects the BIOS or EEPROM to set them =
correctly
> > because different problems different settings.
> >
> > There is firmware in eeprom that configures internal state. On one =
motherboard
> > the vendor provided an update. There is no good way to update this =
from Linux,
> > you need to go system vendor and install firmware with their native=
 OS (ie Windows
> > or MacOS).
>=20
> Perfectly reasonable response.  If there was a firmware update fix,
> I'd apply it...
> That would presumably prevent this from ever happening in the first p=
lace.
>=20
> But why doesn't the network driver reset the nic when it detects this
> 'rx length' error?
>=20
> I'm not asking for the error to not happen (besides it happens very r=
arely)...
>=20
> I'm asking, why does this error happening permanently hose the networ=
k driver.
> Once this happens the network card is not usable - traffic does not
> flow through it.
> You need to "ip link set down && ... up" to fix it.  Isn't this
> something the driver could and should do all by itself?

Also, the driver could schedule a reset (that is what the watchdog does=
),
but it looks like the receive DMA is walking past the end of the packet
and that is really dangerous since it could clobber random memory.

You might want to increase the size of rx DMA buffer and dump the
contents of the receive buffer to see if there is a memory corruption
risk. If the End Of Frame DMA hardware is not working, there is a real
danger if the driver silently continues.

--=20
