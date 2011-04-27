From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH rfc 2/5] r8169: rtl8169_set_speed_xmii cleanup.
Date: Wed, 27 Apr 2011 22:13:37 +0100
Message-ID: <1303938817.2875.148.camel@bwh-desktop>
References: <20110427203702.GE19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36612 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab1D0VNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 17:13:40 -0400
In-Reply-To: <20110427203702.GE19708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-27 at 22:37 +0200, Francois Romieu wrote:
> - use ADVERTISE_ALL
> - shorten chipset version test
> 
> No functional change.
> 
> Careful readers will notice that the 'supports_gmii' flag is deduced
> from the device PCI id. Though less specific than the chipset related
> RTL_GIGA_MAC_VER_XY, it is currently good enough to detect a GMII
> deprieved 810x.
> Some features may push for a device specific configuration (improved
> jumbo frame support for instance). 'supports_gmii' will follow this
> path if / when the device PCI id stops working.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
> ---
>  drivers/net/r8169.c |   14 ++------------
>  1 files changed, 2 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 0bb0c0d..006f0df 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1242,8 +1242,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  		int auto_nego;
>  
>  		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
> -		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
> -				ADVERTISE_100HALF | ADVERTISE_100FULL);
> +		auto_nego &= ADVERTISE_ALL;
[...]

You mean ~ADVERTISE_ALL.  Though ADVERTISE_ALL is really not a good name
and I think this is clearer with the individual advertising flags
spelled out.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

