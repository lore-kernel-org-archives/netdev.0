From: Adrian Bunk <bunk@stusta.de>
Subject: drivers/net/chelsio/my3126.c: inconsequent NULL checking
Date: Thu, 7 Dec 2006 12:34:52 +0100
Message-ID: <20061207113452.GD8963@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1032071AbWLGLes@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following inconsequent NULL checking 
introduced by commit f1d3d38af75789f1b82969b83b69cab540609789:

<--  snip  -->

...
static struct cphy *my3126_phy_create(adapter_t *adapter,
                        int phy_addr, struct mdio_ops *mdio_ops)
{
        struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);

        if (cphy)
                cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);

        INIT_WORK(&cphy->phy_update, my3216_poll, cphy);
        cphy->bmsr = 0;

        return (cphy);
}
...

<--  snip  -->

It doesn't make sense to first check whether "cphy" is NULL and 
dereference it unconditionally later.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
