From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 19:53:56 +0100
Message-ID: <20110621185356.GJ23234@n2100.arm.linux.org.uk>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org> <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca> <20110619073000.GA23171@S2100-06.ap.freescale.net> <20110621135558.GB9228@S2101-09.ap.freescale.net> <4E00E3D2.6050602@firmworks.com> <BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mitch Bradley <wmb@firmworks.com>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:51967 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755153Ab1FUSyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:54:24 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2011 at 12:42:14PM -0600, Grant Likely wrote:
> On Tue, Jun 21, 2011 at 12:32 PM, Mitch Bradley <wmb@firmworks.com> w=
rote:
> > I wonder if it makes sense to create a new device node "/linux-devi=
ces" to express a desired mapping from device nodes to /dev entries? =A0=
The properties could be the names of device special files and the value=
s the corresponding node phandles.
>=20
> I've been trying /really/ hard to avoid doing something like that
> because a lot of the time the desired Linux dev name is a
> implementation detail, and a potentially unstable one at that.  If
> Linux requires certain devices to have certain names because that is
> how it hooks up clocks

As I keep on saying, we don't _have_ to have to match on device name.
If DT can come up with a better way to bind a clock to a particular
device/connection name then DT can provide its own clk_get()
implementation which does that.

clk_get() has the struct device, and therefore can get at the DT
information itself to read out whatever properties are required.  But,
we must not get away from the fact that clk_get()'s second argument
should _never_ be used as a unique clock name itself.

At the moment, until we do have some kind of DT based clk_get(), the
easiest way to move clk-API using drivers over is to use the device
name in the static clk_lookup tables.

It's all an implementation detail, one which is (thankfully) hidden
behind a proper API which will be _completely_ transparent to drivers
using the clk API in the _proper_ way.
