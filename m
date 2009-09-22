From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt Coalescing
Date: Tue, 22 Sep 2009 10:12:41 +1000
Message-ID: <1253578361.7103.180.camel@pasglop>
References: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
	<1253576514.7103.165.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D606FFE802@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, Feng Kan <fkan@amcc.com>,
	netdev@vger.kernel.org, lada.podivin@gmail.com,
	Loc Ho <lho@amcc.com>, bhutchings@solarflare.com,
	linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
To: Prodyut Hazarika <phazarika@amcc.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <0CA0A16855646F4FA96D25A158E299D606FFE802@SDCEXCHANGE01.ad.amcc.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-09-21 at 17:05 -0700, Prodyut Hazarika wrote:
> Hi Ben,
> Thanks again for your comments.
> 
> > Same goes with the SDR register definitions. Prefix them with the SOC
> > name but don't make them conditionally compiled.
> 
> I will add the base address in the Device tree, and make all register
> definitions based on offset from the base in the next version of this
> patch.

That's a good idea. In fact, you can also use the dcr_read/write
variants of the accessors rather than the low level mfdcri/mtdcri. This
wouldn't make much of a difference unless you ever release a SoC with
those same registers behind an MMIO mapping but it's cleaner.

> Thanks for this comment. I will hookup ethtool with the EMAC driver, but
> the MAL driver will come up with default coalesce options (as defined in
> the appropriate defconfig file). The user will be able to change these
> parameters as needed using ethtool.

That's ok. I don't have an objection in using Kconfig to set the
defaults.

> I will get all the changes in place in the next version of this patch.

Thanks !

BTW. If you guys are ever going to do another change to MAL, please
please plase, add the -one- major missing feature that's causing all the
pain and complication in the current design: Add a per-channel interrupt
masking option.

The lack of ability to mask the interrupt per MAL channel is what forces
us to create that fake netdev structure in order to share the napi
device instance between all the EMACs in the system. This is very
inefficient too. We would be able to make things run a lot smoother if
we could just have a napi instance per EMAC, but for that, we need
per-channel interrupt masking.

Cheers,
Ben.
