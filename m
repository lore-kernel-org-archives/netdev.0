From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy state machine: failsafe leave invalid RUNNING
 state
Date: Sun, 08 Jan 2017 18:16:00 -0500 (EST)
Message-ID: <20170108.181600.1132579382984085546.davem@davemloft.net>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
        <1483701288-14019-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753094AbdAHXQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 18:16:02 -0500
In-Reply-To: <1483701288-14019-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Fri,  6 Jan 2017 12:14:48 +0100

> While in RUNNING state, phy_state_machine() checks for link changes by
> comparing phydev->link before and after calling phy_read_status().
> This works as long as it is guaranteed that phydev->link is never
> changed outside the phy_state_machine().
> 
> If in some setups this happens, it causes the state machine to miss
> a link loss and remain RUNNING despite phydev->link being 0.
> 
> This has been observed running a dsa setup with a process continuously
> polling the link states over ethtool each second (SNMPD RFC-1213
> agent). Disconnecting the link on a phy followed by a ETHTOOL_GSET
> causes dsa_slave_get_settings() / dsa_slave_get_link_ksettings() to
> call phy_read_status() and with that modify the link status - and
> with that bricking the phy state machine.
> 
> This patch adds a fail-safe check while in RUNNING, which causes to
> move to CHANGELINK when the link is gone and we are still RUNNING.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> ---
> Changes to v1:
> * fix kbuild test robot error: use phydev_err instead of dev_warn
>   (adapt to changed struct phy_device after 4.4.21)

Florian and Andrew, please provide some feedback on this.

Thank you.
