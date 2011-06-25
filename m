From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC 54/72] au1000_eth/mipsnet/tc35815: Move the MIPS drivers
Date: Sat, 25 Jun 2011 17:13:53 +0100
Message-ID: <20110625161353.GA20976@linux-mips.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-55-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Matt Porter <mporter@kernel.crashing.org>,
	Herbert Valerio Riedel <hvr@gnu.org>,
	MontaVista Software <source@mvista.com>,
	Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	linux-parisc@vger.kernel.org, Sam Creasey <sammy@sammy.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-m68k@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1309010363-22750-55-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 25, 2011 at 06:59:05AM -0700, Jeff Kirsher wrote:

> Move the MIPS drivers into drivers/net/ethernet/mips/ and
> make the necessary Kconfig and Makefile changes.

NAck.

sni_82596.c is a driver for the same chip but used in particular Siemens-
Nixdorf systems.  Lasi_82596 is an Intel NIC being used in PARISC systems.
Not a good reason th throw PA-RISC drivers into the same directory after
all PA-RISC has no relation to MIPS at all.  So maybe they should go into
drivers/net/ethernet/i82596 or drivers/net/ethernet/intel.  And wherever
they go, both drivers #include lib82596.c which your patch did not move
around.

It seems that lp486e should probably go into the same directory and I
suspect ni52 and sun3_82586 are close enough that they should also in
the faint hope that somebody will factor out the common code.

MIPSnet is a driver for the emulated network card of MIPSsim, a software
simulator by MIPS Technologies and the only net thingy in your patch that
truely is "MIPS".

The remaining happen to be used by particular systems that happen to be
based on a MIPS processor but there is no technial communality.  MIPS is
a processor architecture - not a system architecture and grouping things
by processor architecture hasn't worked so well imho for other things in
the past, see for example sound.

If we're already moving things around maybe au1000_net.[ch] can be renamed
to alchemy.[ch].

Your patch moves the Makefile and Kconfig bits of lantiq_etop but doesn't
move the actual lantiq_etop.c driver.

> +++ b/drivers/net/ethernet/mips/Kconfig
> @@ -0,0 +1,61 @@
> +#
> +# MIPS device configuration
> +#
> +
> +config NET_MIPS
> +	bool "MIPS/PS-RISC devices"

It's speeled PA-RISC.

  Ralf
