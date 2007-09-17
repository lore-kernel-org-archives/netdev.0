From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Mon, 17 Sep 2007 18:08:27 -0400
Message-ID: <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: "Domen Puncer" <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:16260 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643AbXIQWI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 18:08:29 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2188608wah
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 15:08:28 -0700 (PDT)
In-Reply-To: <20070917202140.GB2642@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/17/07, Domen Puncer <domen@coderock.org> wrote:
> Export phy_mii_ioctl, so network drivers can use it when built
> as modules too.

Domen, do you want to collect all of these changes for MPC5200 FEC in
to a single patch series? The code is getting scattered around, I'll
check it over to make sure it is all working. I have these patches
applied individually and they all work.

It builds on this series:
[PATCH 0/7] MPC52xx Bestcomm submission for 2.6.24

If you can put this together is a clean series, I should be able to
layer support for the Phytec pcm030 on top of it.

It would be these three combined...

http://coderock.org/tmp/fec-v3rc1/

diff --git a/drivers/net/fec_mpc52xx/fec.c b/drivers/net/fec_mpc52xx/fec.c
index 922e9a8..c4442e0 100644
--- a/drivers/net/fec_mpc52xx/fec.c
+++ b/drivers/net/fec_mpc52xx/fec.c
@@ -1087,11 +1087,13 @@ static struct of_platform_driver mpc52xx_fec_driver = {
 /* ======================================================================== */
 /* Module                                                                   */
 /* ======================================================================== */
+extern int fec_mdio_init(void);
+void fec_mdio_exit(void);

 static int __init
 mpc52xx_fec_init(void)
 {
-#ifdef FEC_MPC52xx_MDIO
+#ifdef CONFIG_FEC_MPC52xx_MDIO
       int ret;
       ret = fec_mdio_init();
       if (ret) {
@@ -1106,7 +1108,7 @@ static void __exit
 mpc52xx_fec_exit(void)
 {
       of_unregister_platform_driver(&mpc52xx_fec_driver);
-#ifdef FEC_MPC52xx_MDIO
+#ifdef CONFIG_FEC_MPC52xx_MDIO
       fec_mdio_exit();
 #endif
 }


>
> Signed-off-by: Domen Puncer <domen@coderock.org>
>
> ---
> On 17/09/07 11:53 +0200, Sven Luther wrote:
> > On Sat, Sep 15, 2007 at 02:14:44PM +0200, Domen Puncer wrote:
> > > Updated and split version at:
> > > http://coderock.org/tmp/fec-v3rc1/
> > >
> > > I'll repost to lists once I run-test them.
> >
> > When applying those patches, the build did die with :
> >
> >
> >   ERROR: "phy_mii_ioctl" [drivers/net/fec_mpc52xx/fec_mpc52xx.ko] undefined!
> >
> > Apparently, phy_mii_ioctl is not an exported symbol.
> >
> > Domen, did you maybe forget a little snipplet when you cut the patches
> > in different pieces ? Or did i mess up applying them ?
> >
> > Friendly,
> >
> > Sven Luther
>
>
>  drivers/net/phy/phy.c |    1 +
>  1 files changed, 1 insertion(+)
>
> Index: linux.git/drivers/net/phy/phy.c
> ===================================================================
> --- linux.git.orig/drivers/net/phy/phy.c
> +++ linux.git/drivers/net/phy/phy.c
> @@ -409,6 +409,7 @@ int phy_mii_ioctl(struct phy_device *phy
>
>         return 0;
>  }
> +EXPORT_SYMBOL(phy_mii_ioctl);
>
>  /**
>   * phy_start_aneg - start auto-negotiation for this PHY device
>
> _______________________________________________
> Linuxppc-embedded mailing list
> Linuxppc-embedded@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-embedded
>


-- 
Jon Smirl
jonsmirl@gmail.com
