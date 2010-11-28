From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sat, 27 Nov 2010 16:21:35 -0800
Message-ID: <20101128002135.GA4562@suse.de>
References: <1290897868.3292.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-arm-kernel@lists.infradead.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60025 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab0K1AVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 19:21:43 -0500
Content-Disposition: inline
In-Reply-To: <1290897868.3292.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 27, 2010 at 10:44:28PM +0000, Ben Hutchings wrote:
> Recent review has revealed several bugs in econet and other obscure
> protocol implementations that can be exploited by local users for
> denial of service or privilege escalation.
> 
> The econet protocol (PF_ECONET) is unmaintained.  There appear to be
> no published applications for it, and it has never progressed beyond
> 'experimental' status.
> 
> This protocol generally should not be enabled by distributions, since
> the cost of a security flaw affecting all installed systems presumably
> outweighs the benefit to the few (if any) legitimate users.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> As requested, I'm actually renaming the directory this time.  I also
> noticed that ECONET was enabled in a couple of ARM defconfigs and
> explicitly disabled in various other defconfigs, so I've removed those
> lines as well.
> 
> This is based on linux-next; I hope it applies to staging.
> 
> Ben.
> 
>  arch/arm/configs/ixp4xx_defconfig           |    3 ---
>  arch/arm/configs/pnx4008_defconfig          |    3 ---
>  arch/mips/configs/gpr_defconfig             |    3 ---
>  arch/mips/configs/mtx1_defconfig            |    3 ---
>  arch/um/defconfig                           |    1 -
>  arch/xtensa/configs/common_defconfig        |    1 -
>  arch/xtensa/configs/iss_defconfig           |    1 -
>  arch/xtensa/configs/s6105_defconfig         |    1 -

No need to change the defconfigs, they will get updated on their own if
they need to be.

>  drivers/staging/Kconfig                     |    2 ++
>  drivers/staging/Makefile                    |    1 +
>  {net => drivers/staging}/econet/Kconfig     |    0
>  {net => drivers/staging}/econet/Makefile    |    0
>  {net => drivers/staging}/econet/af_econet.c |    0
>  net/Kconfig                                 |    1 -
>  net/Makefile                                |    1 -
>  15 files changed, 3 insertions(+), 18 deletions(-)
>  rename {net => drivers/staging}/econet/Kconfig (100%)
>  rename {net => drivers/staging}/econet/Makefile (100%)
>  rename {net => drivers/staging}/econet/af_econet.c (100%)
> 
> diff --git a/arch/arm/configs/ixp4xx_defconfig b/arch/arm/configs/ixp4xx_defconfig
> index 5c50239..bd85c32 100644
> --- a/arch/arm/configs/ixp4xx_defconfig
> +++ b/arch/arm/configs/ixp4xx_defconfig
> @@ -88,9 +88,6 @@ CONFIG_IPDDP_ENCAP=y
>  CONFIG_IPDDP_DECAP=y
>  CONFIG_X25=m
>  CONFIG_LAPB=m
> -CONFIG_ECONET=m
> -CONFIG_ECONET_AUNUDP=y
> -CONFIG_ECONET_NATIVE=y

Doesn't this imply that someone is actually using this?

>  CONFIG_WAN_ROUTER=m
>  CONFIG_NET_SCHED=y
>  CONFIG_NET_SCH_CBQ=m
> diff --git a/arch/arm/configs/pnx4008_defconfig b/arch/arm/configs/pnx4008_defconfig
> index bd481f0..8301e4a 100644
> --- a/arch/arm/configs/pnx4008_defconfig
> +++ b/arch/arm/configs/pnx4008_defconfig
> @@ -101,9 +101,6 @@ CONFIG_IPDDP_ENCAP=y
>  CONFIG_IPDDP_DECAP=y
>  CONFIG_X25=m
>  CONFIG_LAPB=m
> -CONFIG_ECONET=m
> -CONFIG_ECONET_AUNUDP=y
> -CONFIG_ECONET_NATIVE=y

Same here and for the others.

I also need a TODO file for the staging directory location (see the
others for drivers that are going away as an example.)

And I need an ack from the networking maintainer to be able to accept
this also.

thanks,

greg k-h
