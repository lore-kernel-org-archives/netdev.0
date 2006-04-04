From: Adrian Bunk <bunk@stusta.de>
Subject: bcm43xx_power.c: uninitialized variable used
Date: Tue, 4 Apr 2006 20:44:18 +0200
Message-ID: <20060404184418.GU6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750794AbWDDSoW@vger.kernel.org>
To: Martin Langer <martin-langer@gmx.de>,
	Stefano Brivio <st3@riseup.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Danny van Dyk <kugelfang@gentoo.org>,
	Andreas Jaggi <andreas.jaggi@waterwave.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker found this case where the variable "tmp" is used 
uninitialized:

<--  snip  -->

...
static int bcm43xx_pctl_clockfreqlimit(struct bcm43xx_private *bcm,
                                       int get_max)
{
        int limit = 0;
        int divisor;
        int selection;
        int err;
        u32 tmp;
        struct bcm43xx_coreinfo *old_core;

        if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
                goto out;
        old_core = bcm->current_core;
        err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
        if (err)
                goto out;

        if (bcm->current_core->rev < 6) {
...
        } else if (bcm->current_core->rev < 10) {
                selection = (tmp & 0x07);
...

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
