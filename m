From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: Re: [PATCH] net: sun4i-emac: Claim emac sram
Date: Mon, 24 Aug 2015 15:39:02 +0200
Message-ID: <20150824133902.GQ2413@lukather>
References: <1440354698-11144-1-git-send-email-hdegoede@redhat.com>
 <20150824074605.GF2413@lukather>
 <55DAE137.4040306@redhat.com>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="im83/wVv0jiGQj4J"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jelle van der Waa <jelle-oJJ1AqDjjO4@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRB5545SXAKGQEUGGTUYQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55DAE137.4040306-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

--im83/wVv0jiGQj4J
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

On Mon, Aug 24, 2015 at 11:17:43AM +0200, Hans de Goede wrote:
> Hi,
> 
> On 24-08-15 09:46, Maxime Ripard wrote:
> >Hi Hans,
> >
> >On Sun, Aug 23, 2015 at 08:31:38PM +0200, Hans de Goede wrote:
> >>Claim the emac sram ourselves, rather then relying on the bootloader
> >>having mapped the sram to the emac controller during boot.
> >>
> >>Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >>---
> >>  drivers/net/ethernet/allwinner/sun4i-emac.c | 13 +++++++++++--
> >>  1 file changed, 11 insertions(+), 2 deletions(-)
> >>
> >>diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
> >>index bab01c84..48ce83e 100644
> >>--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
> >>+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
> >>@@ -28,6 +28,7 @@
> >>  #include <linux/of_platform.h>
> >>  #include <linux/platform_device.h>
> >>  #include <linux/phy.h>
> >>+#include <linux/soc/sunxi/sunxi_sram.h>
> >>
> >>  #include "sun4i-emac.h"
> >>
> >>@@ -857,11 +858,17 @@ static int emac_probe(struct platform_device *pdev)
> >>
> >>  	clk_prepare_enable(db->clk);
> >>
> >>+	ret = sunxi_sram_claim(&pdev->dev);
> >>+	if (ret) {
> >>+		dev_err(&pdev->dev, "Error couldn't map SRAM to device\n");
> >>+		goto out;
> >
> >Shouldn't you disable you clock too?
> 
> You're right, but that is a pre-existing problem, iow an unrelated
> issue.
> 
> I've put doing a follow-up patch for this on my todo list.

Thanks.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
--im83/wVv0jiGQj4J--
