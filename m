From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sun, 3 Aug 2003 01:27:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803002744.GF22222@parcelfarce.linux.theplanet.co.uk>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk> <20030801162536.GA18574@gtf.org> <20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk> <3F2C3C86.6000202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F2C3C86.6000202@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 02, 2003 at 06:34:46PM -0400, Jeff Garzik wrote:
> >diff -u include/linux/netdevice.h include/linux/netdevice.h
> >--- include/linux/netdevice.h   31 Jul 2003 13:06:23 -0000
> >+++ include/linux/netdevice.h   2 Aug 2003 18:37:16 -0000
> >@@ -477,6 +477,10 @@
> >  */
> > #define SET_NETDEV_DEV(net, pdev)      ((net)->class_dev.dev = (pdev))
> > 
> >+static inline void set_ethtool_ops(struct net_device *dev, struct 
> >ethtool_ops *
> >ops)
> >+{
> >+       dev->ethtool_ops = ops;
> >+}
> 
> 
> It needs to be a macro for maximum flexibility.

Nothing stops it being implemented as a macro in kcompat.  Having it as
an inline function gives it argument typechecking which always gives me
the warm fuzzies.

> Also, no need to convert in-kernel drivers over to using it...  Let 
> driver authors use it or not as they choose.

I took "Like pci_set_drvdata" as the most important part of your
argument...  having everyone use it is no bad thing.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
