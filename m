From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] mii: Remove references to DP83840 PHY in mii.h
Date: Wed, 31 Aug 2011 18:34:30 +0100
Message-ID: <1314812070.3274.19.camel@bwh-desktop>
References: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43652 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736Ab1HaRed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 13:34:33 -0400
In-Reply-To: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 16:35 +0100, Mark Einon wrote:
> There are references to this PHY chip in the generic mii.h header, so removing them.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
>  include/linux/mii.h |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/mii.h b/include/linux/mii.h
> index 103113a..4c3cfb5 100644
> --- a/include/linux/mii.h
> +++ b/include/linux/mii.h
> @@ -40,12 +40,12 @@
>  #define BMCR_CTST               0x0080  /* Collision test              */
>  #define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
>  #define BMCR_ANRESTART          0x0200  /* Auto negotiation restart    */
> -#define BMCR_ISOLATE            0x0400  /* Disconnect DP83840 from MII */
> -#define BMCR_PDOWN              0x0800  /* Powerdown the DP83840       */
> +#define BMCR_ISOLATE            0x0400  /* Disconnect PHY from MII     */

Since you're trying to improve these comments, I think this could do
with further improvement.  When this bit is set, the PHY's data paths
are isolated from the MII (or other interface to the MAC).  The control
path is still connected to the management interface (MDIO), which is
important when we want to clear this bit!  So it would be better to say
something like 'Isolate data paths fromn MII'.

> +#define BMCR_PDOWN              0x0800  /* Powerdown                   */

This selects a low-power state (if implemented).  It doesn't entirely
turn the PHY off, and at least the management interface must stil be
functional.  So it would be better to say 'Request low-power state'.

>  #define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
>  #define BMCR_SPEED100           0x2000  /* Select 100Mbps              */
>  #define BMCR_LOOPBACK           0x4000  /* TXD loopback bits           */
> -#define BMCR_RESET              0x8000  /* Reset the DP83840           */
> +#define BMCR_RESET              0x8000  /* Reset                       */
>  
>  /* Basic mode status register. */
>  #define BMSR_ERCAP              0x0001  /* Ext-reg capability          */
> @@ -55,9 +55,9 @@
>  #define BMSR_RFAULT             0x0010  /* Remote fault detected       */
>  #define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
>  #define BMSR_RESV               0x00c0  /* Unused...                   */
> -#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
> -#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX */
> -#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX */
> +#define BMSR_ESTATEN		0x0100	/* Extended Status in R15      */
> +#define BMSR_100HALF2           0x0200  /* Can do 100BASE-T2 HDX       */
> +#define BMSR_100FULL2           0x0400  /* Can do 100BASE-T2 FDX       */

This formatting change is unrelated.  If you're going to fix formatting
then please convert spaces to tabs after each name and value.

Ben.

>  #define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
>  #define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
>  #define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
