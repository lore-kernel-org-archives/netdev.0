From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: remove bcmgenet_internal_phy_setup()
Date: Wed, 22 Mar 2017 12:49:10 -0700 (PDT)
Message-ID: <20170322.124910.879716567254407023.davem@davemloft.net>
References: <20170321210106.3875-1-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: opendmb@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321210106.3875-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <opendmb@gmail.com>
Date: Tue, 21 Mar 2017 14:01:06 -0700

> Commit 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset")
> removed the bcmgenet_mii_reset() function from bcmgenet_power_up() and
> bcmgenet_internal_phy_setup() functions.  In so doing it broke the reset
> of the internal PHY devices used by the GENETv1-GENETv3 which required
> this reset before the UniMAC was enabled.  It also broke the internal
> GPHY devices used by the GENETv4 because the config_init that installed
> the AFE workaround was no longer occurring after the reset of the GPHY
> performed by bcmgenet_phy_power_set() in bcmgenet_internal_phy_setup().
> In addition the code in bcmgenet_internal_phy_setup() related to the
> "enable APD" comment goes with the bcmgenet_mii_reset() so it should
> have also been removed.
> 
> Commit bd4060a6108b ("net: bcmgenet: Power on integrated GPHY in
> bcmgenet_power_up()") moved the bcmgenet_phy_power_set() call to the
> bcmgenet_power_up() function, but failed to remove it from the
> bcmgenet_internal_phy_setup() function.  Had it done so, the
> bcmgenet_internal_phy_setup() function would have been empty and could
> have been removed at that time.
> 
> Commit 5dbebbb44a6a ("net: bcmgenet: Software reset EPHY after power on")
> was submitted to correct the functional problems introduced by
> commit 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset"). It
> was included in v4.4 and made available on 4.3-stable. Unfortunately,
> it didn't fully revert the commit because this bcmgenet_mii_reset()
> doesn't apply the soft reset to the internal GPHY used by GENETv4 like
> the previous one did. This prevents the restoration of the AFE work-
> arounds for internal GPHY devices after the bcmgenet_phy_power_set() in
> bcmgenet_internal_phy_setup().
> 
> This commit takes the alternate approach of removing the unnecessary
> bcmgenet_internal_phy_setup() function which shouldn't have been in v4.3
> so that when bcmgenet_mii_reset() was restored it should have only gone
> into bcmgenet_power_up().  This will avoid the problems while also
> removing the redundancy (and hopefully some of the confusion).
> 
> Fixes: 6ac3ce8295e6 ("net: bcmgenet: Remove excessive PHY reset")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Applied and queued up for -stable, thanks.
