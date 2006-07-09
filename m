From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG/PATCH/RFC] bridge: locally generated broadcast
 traffic may block sender
Date: Sat, 8 Jul 2006 22:32:40 -0700
Message-ID: <20060708223240.57cfd14f@localhost.localdomain>
References: <65170.217.5.191.115.1152028122.squirrel@sesamstrasse.dyndns.tv>
	<20060707153648.694f84c2@dxpl.pdx.osdl.net>
	<43150.217.5.191.115.1152350639.squirrel@sesamstrasse.dyndns.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@kernel.org, bridge@lists.osdl.org, Wolfgang Denk <wd@denx.de>
Return-path: <bridge-bounces@lists.osdl.org>
To: "Bernd Kischnick" <kisch@sesamstrasse.dyndns.tv>
In-Reply-To: <43150.217.5.191.115.1152350639.squirrel@sesamstrasse.dyndns.tv>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Sat, 8 Jul 2006 11:23:59 +0200 (CEST)
"Bernd Kischnick" <kisch@sesamstrasse.dyndns.tv> wrote:

> =

> On Sa, 8.07.2006, 00:36, Stephen Hemminger explained:
> =

> > The fix is not acceptable, because it eliminatess the whole sender memo=
ry
> > flow control limitation.
> >
> > The root cause is that the device incorrectly holds onto packets when
> > the carrier is lost. The device should clear it's own queue.
> > What hardware is this?
> >
> =

> That's the built-in Ethernet MAC of the 82xx series Motorola PowerQUICC
> CPUs. The driver is 2.4.32:arch/ppc/cpm2_io/fcc_enet.c, or
> 2.6.17.3:arch/ppc/8260_io/fcc_enet.c, with modifications by
> Wolfgang Denk to support a specific PHY chip.
> =

> Of course I've been examinating the driver first. It's obvious that the
> bridge code experiences much broader testing than the odd driver for
> the odd embedded target. But I didn't see a way to have the driver handle
> this problem correctly.

The driver doesn't handle carrier properly.
It needs to call netif_carrier_off when carrier is lost, and netif_carrier_=
on
when carrier is detected. This is done in some drivers by phy interrupt, and
in others by polling the carrier status.

Bridging can't detect lost links and do fail over without it.
