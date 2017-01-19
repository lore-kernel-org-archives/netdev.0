From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: Initializing MAC address at run-time
Date: Thu, 19 Jan 2017 17:26:52 +0100
Message-ID: <20170119162652.yef3ni6ylhzxpvgz@pengutronix.de>
References: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
 <20170118185435.fen6np7lydzgxxek@pengutronix.de>
 <79fef293-74ec-dece-1941-747cd55f1ca2@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>, DT <devicetree@vger.kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Kevin Hilman <khilman@kernel.org>,
 netdev <netdev@vger.kernel.org>,
 Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <79fef293-74ec-dece-1941-747cd55f1ca2@free.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Jan 19, 2017 at 04:31:56PM +0100, Mason wrote:
> Do you agree that such boot loader would execute code that is roughly
> identical to the one posted for illustration purposes?
>   1. find the MAC address to use for eth0
>   2. find the eth0 node in the DT
>   3. insert the right prop in the eth0 node

yes.
 =

> In which case, it seems a waste to add the DT library to the boot
> loader, when the operation can be done in Linux, which requires the
> DT library anyway. (Additionally, adding DT support to some custom
> legacy boot loader might be a complex task.)

With this reasoning you can discuss away the bootloader. Linux relies on
a bootloader for a reason. It's there to initialize RAM and some further
things that Linux might not be able to and provide a machine description
to Linux (either in form of a dtb or an ATAG list) such that Linux
doesn't need to fiddle with machine specific stuff in early init code.

> >  c) Adapt the dtb before it is written to the boot medium.
> =

> This is not applicable, as the DTB is not written to the board.

Ah, then adapt the dtb before it is put into the tftp folder.

> >  d) Let the bootloader configure the device and teach the driver to pick
> >     up the mac from the device's address space.
> =

> I'm not sure what you call "the device" ?

The network device. IIRC the fec driver checks if there is something
configured in the two registers configuring the MAC before falling back
to a random MAC.

> >  e) Accept that the mac address is random during development, and make
> >     Userspace configure the MAC address, which is early enough for
> >     production use.
> =

> During development, some devs configure the DHCP server to provide
> a specific uImage and/or rootfs to their board, based on the MAC
> address. This scheme would fall apart with a random MAC.
> =

> > Not sure d) is considered ok today, but some drivers have this feature.
> > I'd say b) is the best choice.
> =

> In my mind, doing it early in Linux is similar in spirit to doing it
> at the boot loader stage, in that it's neatly separated from the rest
> of the setup.

Sure you can do this. But it won't be accepted mainline for sure.

Best regards
Uwe

-- =

Pengutronix e.K.                           | Uwe Kleine-K=F6nig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
