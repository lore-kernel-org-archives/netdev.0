From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: Initializing MAC address at run-time
Date: Wed, 18 Jan 2017 19:54:35 +0100
Message-ID: <20170118185435.fen6np7lydzgxxek@pengutronix.de>
References: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
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
In-Reply-To: <e083ed68-0e8e-380e-23bd-5ad387c88575@free.fr>
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

On Wed, Jan 18, 2017 at 03:03:57PM +0100, Mason wrote:
> When my system boots up, eth0 is given a seemingly random MAC address.
> =

> [    0.950734] nb8800 26000.ethernet eth0: MAC address ba:de:d6:38:b8:38
> [    0.957334] nb8800 26000.ethernet eth0: MAC address 6e:f1:48:de:d6:c4
> =

> =

> The DT node for eth0 is:
> =

> 	eth0: ethernet@26000 {
> 		compatible =3D "sigma,smp8734-ethernet";
> 		reg =3D <0x26000 0x800>;
> 		interrupts =3D <38 IRQ_TYPE_LEVEL_HIGH>;
> 		clocks =3D <&clkgen SYS_CLK>;
> 	};
> =

> Documentation/devicetree/bindings/net/ethernet.txt mentions
> - local-mac-address: array of 6 bytes, specifies the MAC address that was
>   assigned to the network device;
> =

> And indeed, if I define this property, eth0 ends up with the MAC address
> I specify in the device tree. But of course, I don't want all my boards
> to share the same MAC address. Every interface has a unique MAC address.
> =

> In fact, the boot loader (not Uboot, a custom non-DT boot loader) stores
> the MAC address somewhere in MMIO space, in some weird custom format.

Where does your machine get the dtb from? You write it to the boot
medium at a certain point of time I assume. So AFAICT you have the
following options (in no particular order):

 a) Describe in the dtb how to find out how the MAC address is stored
    (already pointed out Mark and Robin)
 b) Make your bootloader dt aware and let it provide the
    local-mac-address property.
 c) Adapt the dtb before it is written to the boot medium.
 d) Let the bootloader configure the device and teach the driver to pick
    up the mac from the device's address space.
 e) Accept that the mac address is random during development, and make
    Userspace configure the MAC address, which is early enough for
    production use.

Not sure d) is considered ok today, but some drivers have this feature.
I'd say b) is the best choice.

> I need to do something similar with the NAND partitions. The boot loader
> stores the partition offsets somewhere, and I need to pass this info
> to the NAND framework, so I assumed that inserting the corresponding
> properties at run-time was the correct way to do it.

The list of options here is similar to the list above. d) doesn't work,
but instead you can pass the partitioning on the kernel commandline.

Best regards
Uwe

-- =

Pengutronix e.K.                           | Uwe Kleine-K=F6nig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
