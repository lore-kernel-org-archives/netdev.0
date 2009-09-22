From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt Coalescing
Date: Tue, 22 Sep 2009 10:07:07 +1000
Message-ID: <1253578027.7103.177.camel@pasglop>
References: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
	<1253576514.7103.165.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D606FFE7FF@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, Feng Kan <fkan@amcc.com>,
	netdev@vger.kernel.org, lada.podivin@gmail.com,
	Loc Ho <lho@amcc.com>, bhutchings@solarflare.com,
	linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
To: Prodyut Hazarika <phazarika@amcc.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <0CA0A16855646F4FA96D25A158E299D606FFE7FF@SDCEXCHANGE01.ad.amcc.com>
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

On Mon, 2009-09-21 at 16:49 -0700, Prodyut Hazarika wrote:
> Hi Ben,
> Thanks for your comments.
> 
> 
> > What happens if we build a kernel that is supposed to boot with two
> > different variants of 405 or 440 ?
> 
> We cannot build a kernel with H/W Interrupt coalescing other than in
> 405EX/460EX/GT.
> This is controlled via KConfig (config IBM_NEW_EMAC_INTR_COALESCE
> depends on IBM_NEW_EMAC && (460EX || 460GT || 405EX))
> Is this approach acceptable (via Kconfig)?

No. That's my point. All of this must be runtime options. The kernel
must be buildablt for 460EX -and- 460GT - and an old 440EP if I want to
in a single image, and this -with- the coalescing option enabled. It
would obviously only be available when running on the cores that support
it, but it should -not- be a compile time decision.

IE. All your ifdef's should be turned into runtime checks. If you have
conflicting #define for register names and bits, then prefix them with
the SoC name.

The only acceptable compile-time option is to have the ability to not
compile the coalescing support at all, thus avoiding bloat when building
configs that are only targeted toward processors that don't have it or
setups that don't want it. 

> > There are existing mechanisms via ethtool to configure coalescing. You
> > should hookup onto these.
> 
> I will start looking at the ethtool options

Thanks.

Cheers,
Ben.
